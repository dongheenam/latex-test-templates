% ib-exam.cls
% 
% for creating an IB-style Maths exams
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ib-exam}[2022/04/20 IB-style exam template]

% use exam class ... for now
\LoadClass[11pt, addpoints]{exam}
\pagenumbering{arabic}

% load necessary packages
\RequirePackage{tikz}               % drawing figures
    \usetikzlibrary{calc}
\RequirePackage{enumitem}           % custom lists
\RequirePackage{geometry}           % margin control
\RequirePackage{iftex}              % check if the document is compiled with XeTeX

% set the geometry of the paper
\geometry{
%    showframe,
    a4paper,
    vmargin={2.4cm, 2.5cm}, hmargin={1.5cm, 1.5cm},
    headsep=0.45cm,
    footskip=0.6cm,
    marginparwidth=0cm,
    marginparsep=0cm
}

% set default font to be Arial for text and TeX Gyre Termes for Maths
% this requires XeTeX or LuaTeX compilers
\iftutex
    \RequirePackage[no-math]{fontspec}
    \RequirePackage[
        warnings-off={mathtools-colon,mathtools-overbracket}
    ]{unicode-math}
    \defaultfontfeatures{ Ligatures=TeX }
    \setmainfont[Scale=1.00833333]{Arial}
    \setmathfont[Scale=MatchLowercase]{TeX Gyre Termes Math}
    \setmathrm[Scale=MatchLowercase]{TeX Gyre Termes Math}
% if LaTeX or pdfLaTeX are used, use TX fonts for text and Maths
\else
    \ClassWarning{ib-exams}{XeTeX or LuaTeX not used. TX fonts will be loaded instead of Arial and TeX Gyre Termes.}
    \RequirePackage[utf8]{inputenc}
    \RequirePackage{newtxtext,newtxmath}
\fi

% length adjustments
\setlength{\parindent}{0pt}
\setlength{\parskip}{2.3ex}
\linespread{0.97}

\renewcommand{\questionshook}{%
    \setlength{\leftmargin}{1cm}%
    \setlength{\rightmargin}{1.2cm}%
    \setlength{\labelsep}{1cm}%
    \setlength{\listparindent}{0cm}%
    \setlength{\itemindent}{0cm}%
    \setlength{\itemsep}{0cm}%
    \setlength{\parsep}{2.3ex}%
    \setlength{\topsep}{1.1ex}%
}
\renewcommand{\partshook}{%
    \setlength{\leftmargin}{1cm}%
    \setlength{\labelsep}{1cm - \labelwidth}%
    \setlength{\itemindent}{0cm}
    \setlength{\listparindent}{0cm}%
    \setlength{\itemsep}{-0.1ex}%
    \setlength{\parsep}{2.2ex}%
    \renewcommand\makelabel[1]{\rlap{##1}\hss}% left align the labels
}
\renewcommand{\subpartshook}{%
    \setlength{\leftmargin}{1cm}%
    \setlength{\labelsep}{1cm - \labelwidth}%
    \setlength{\listparindent}{0cm}%
    \setlength{\itemindent}{0cm}%
    \setlength{\itemsep}{-0.1ex}%
    \setlength{\parsep}{2.2ex}%
    \renewcommand\makelabel[1]{\rlap{##1}\hss}% left align the labels
}

% settings for the exam class
\pointsdroppedatright
\bracketedpoints
\renewcommand\questionlabel{\rlap{\textbf{\thequestion.}}}
\renewcommand{\subpartlabel}{(\thesubpart)}
\totalformat{[Maximum mark: \totalpoints]}
% redefine total points and points placement
\def\droptotalpoints{%
  \total@block \hfill \par%
}
\def\droppoints{%
  \marginpar{\llap{\padded@point@block}}%
}
% put \droptotalpoints right after a question starts
\let\originalquestions\questions
\def\questions{%
    \originalquestions%
    \let\originalquestion\question%
    \renewcommand\question[1][0]{%
        \originalquestion[##1] \droptotalpoints%
    }%
}
% put a lastpage reference before \end{questions}
% so that we can track the number of pages for the questions
\let\originalendquestions\endquestions
\def\endquestions{%
    \label{lastpage}\originalendquestions%
}
% redefine \uplevel so that it respects the right margin
\newlength{\q@rightmargin}
{\questionshook \global\setlength\q@rightmargin\rightmargin }
\long\def\expl#1{%
  \par\vspace{\bigskipamount+4pt}%
  \vbox{%
    % We entered internal vertical mode, and so we get \parshape=0.
    % We set \leftskip to provide the correct left margin for whatever
    % is in the argument of the \uplevel command:
    \leftskip=\@totalleftmargin%
    \advance\leftskip-\leftmargin%
    % We adjust \@totalleftmargin and linewidth in case there's a
    % solution environment inside of the argument to the \uplevel:
    \advance\@totalleftmargin-\leftmargin%
    \advance\linewidth\leftmargin%
    % increase \rightskip by the amount defined in \questionshook
    \advance\rightskip\q@rightmargin%
    #1%
  }% vbox
  \nobreak
}
% redefine \fullwidth so that it respects the right margin
\long\def\fullwidth#1{%
  \par\bigskip
  \vbox{%
    % We entered internal vertical mode, and so we get \parshape=0.
    \leftskip=0pt \rightskip=0pt%
    \linewidth=\textwidth%
    \@totalleftmargin=0pt%
    #1%
  }% vbox
  \nobreak
}


% page borders
\def\pageborder{%
\begin{tikzpicture}[remember picture, overlay]%
    \node at (current page.center) {\includegraphics{source/graphics/tikz/page-margin.pdf}};%
\end{tikzpicture}%
}
% bindings
\def\leftbinding{%
\begin{tikzpicture}[remember picture, overlay]%
    \node[anchor=west,inner sep=0pt] at (current page.west) {\includegraphics{source/graphics/tikz/binding-left.pdf}};%
\end{tikzpicture}
}
\def\rightbinding{%
\begin{tikzpicture}[remember picture, overlay]%
    \node[anchor=east,inner sep=0pt] at (current page.east) {\includegraphics{source/graphics/tikz/binding-right.pdf}};%
\end{tikzpicture}
}
% logos
\newif\if@useiblogos
\@useiblogosfalse
\def\useiblogos{ \@useiblogostrue }
\def\toplogo{ \if@useiblogos source/graphics/iblogo_1 \else source/graphics/ibphlogo_1 \fi }
\def\botlogo{ \if@useiblogos source/graphics/iblogo_2 \else source/graphics/ibphlogo_2 \fi }
\def\logos{
\begin{tikzpicture}[remember picture, overlay]% top logo
    \node[anchor=north east,inner sep=0pt] at ($ (current page.north east)+(-1.95,-0.95) $) {\includegraphics{\toplogo}};
\end{tikzpicture}
\begin{tikzpicture}[remember picture, overlay]% bottom logo
    \node[anchor=south east,inner sep=0pt] at (current page.south east) {\includegraphics{\botlogo}};
\end{tikzpicture}
}
% set header and footer
\def\setlfooter{% set the left footer
\pageborder% use the footer to draw the page border
% use the footer to draw the bindings
\ifodd\thepage \leftbinding%
\else \rightbinding%
\fi%
% use the footer to draw the logos
\ifnum\thepage=1 \logos \fi
}
\def\setheader{% set the header
\ifnum\thepage=1 \else% no header for page 1
\ifnum\thepage>\pageref{lastpage} \else% no header after \end{questions}
    {-- \thepage\ --}%
\fi \fi%
}
\def\setrfooter{% set the right footer
\ifnum\thepage=1 \else% no footer for page 1
\ifnum\thepage=\pageref{lastpage} % footer for the last page
    \textbf{END OF EXAM}%
\else%
\ifnum\thepage>\pageref{lastpage} \else% no footer after \end{questions}
\ifodd\thepage% footer for the odd pages
    \textbf{Turn over}%
\fi \fi \fi \fi%
}
\header{}{\setheader}{}
\footer{\setlfooter}{}{\setrfooter}



%%%%%%%%%%%%%%%%%% MAKETITLE SETUP
% definition for the length of test
\newcommand\testlength[1]{ \gdef\@testlength{#1} }
% definition for the instructions
\newbox\@instructions
\newlist{@instructionslist}{itemize}{1}
\setlist[@instructionslist]{
    label={\raisebox{-0.2\height}{\Large\textbullet}},
    left=0pt,
    labelsep=0.82em,
    rightmargin=2cm,
    nosep
}
\newenvironment{instructionslist}%
    {\global\setbox\@instructions=\vbox\bgroup\begin{@instructionslist}}%
    {\end{@instructionslist}\egroup}
% option to print space for a name or candidate number
\newif\ifnumberbox
\numberboxfalse
\def\numberbox{ \numberboxtrue }
\newif\ifnamebox
\nameboxfalse
\def\namebox{ \nameboxtrue }
% definition for the candidate session number box
\def\sessionnumberinput{%
\begin{tikzpicture}%
    \draw[line width=0.6pt] (0,0) rectangle node[anchor=south,above=11] {Candidate session number} (8.1, 0.8);
    \foreach \x in {0,0.8,1.6,2.4,3.2,4.0,4.8,4.9,5.7,6.5,7.3,8.1} {
        \draw[line width=0.6pt] (\x, 0) -- ++(0, 0.8);
    }
\end{tikzpicture}%
}
% definition for the name box
\def\nameinput{%
\begin{tikzpicture}%
    \draw[line width=0.6pt] (0,0) rectangle node[anchor=south,yshift=0.5cm] {Student name} (8.1, 1.0);
\end{tikzpicture}%
}
% draw tables for marks
\def\drawgradetable{%
    \cellwidth{3.5em}%
    \hpword{Marks:}%
    \hsword{\parbox[c][3em][l]{4em}{\vfill Scores: \vfill}}%
    % the number of rows equal to roundup( \numquestions / 8 )
    \multirowgradetable{\numexpr (\numquestions+4)/8}[questions]\par%
}


% modify maketitle
\renewcommand\maketitle{%
    \newgeometry{vmargin={2.9cm, 2.5cm}, hmargin={2cm, 2cm}, noheadfoot, nomarginpar}%
    \setlength{\parskip}{1.3ex}
    \begin{flushleft} \fontsize{12.94086}{15.529032}\selectfont \textbf \@title \\[4ex] \end{flushleft}%
    \begin{tabular*}{\linewidth}{@{} l @{\extracolsep{\fill}} r @{}}%
        \parbox[b][8ex]{0.45\linewidth}{ \@date \vfill \@testlength } & %
        \ifnumberbox\sessionnumberinput\else\ifnamebox\nameinput\fi\fi%
    \end{tabular*}%
    \par\vspace{0.1cm}%
    \rule{\textwidth}{0.8pt}\par%
    \textbf{Instructions to candidates}\par%
    \unvbox\@instructions%
    \vfill%
    \drawgradetable%
    \vspace{1cm}%
    \hspace{2.3em} \pageref{lastpage}\ pages%
    \newpage%
    \restoregeometry%
    %\setlength{\parskip}{1.2ex}
}%

%%%%%%%%%%%%%%%%%% custom commands and environments

% a better fraction that follows IB style
% usage: \tfrac{numerator}{denominator}
\renewcommand{\tfrac}[2]{\genfrac{}{}{}{1}{\textstyle{#1}}{\textstyle{#2}}}

% make box that fits the IB styling
\newlength{\boxheight}
\newcommand\makeanswerbox[1][\dimexpr \pagegoal-\pagetotal-\bigskipamount \relax]{%
\par\bigskip%
\setlength{\boxheight}{#1}%
\def\maxdashedheight{%
    \ifdim\boxheight>9cm% the maximum height for the dashed section of the answer box is 9 cm
    -9%
    \else% if the box is smaller than 9cm then reduce the dashed section
    % 0.035146pt = 1cm, so 0.035146\boxheight gives \boxheight in cm
    % subtract 0.74cm from the boxheight so that there is at least one line of space on the bottom
    -\dimexpr 0.035146\boxheight - 0.74pt \relax%
    \fi%
}% end \maxdashedheight
\vbox to \boxheight{% setting up a full-width box
\leftskip=-0.2pt \rightskip=-0.2pt% accounting for the width of the line
\begin{tikzpicture}
    \draw (0,0) rectangle (\textwidth, -\boxheight+0.4pt);
    \foreach \y in {-0.74,-1.455,...,\maxdashedheight} {
        \draw[line width=1.2pt, dash pattern=on 1.2pt off 4.94pt, dash phase=-3.5pt] (1,\y) -- ++(\textwidth-2cm,0);
    }
\end{tikzpicture}
}% end \vbox
}% end \newcommand

% insert (continue on the following page) and (continued)
\def\continue{%
    \par
    \fullwidth{ \textbf{(This question continues on the following page)} }
    \newpage
    \fullwidth{ \textbf{(Question \thequestion\ continued)} } \par%
}

% insert "do not write on this page"
\def\donotwrite{%
    \par
    \begin{tikzpicture}[remember picture, overlay]
        \node[draw,align=center,inner sep=0.6cm]
            at (current page.center) 
            {Please \textbf{do not} write on this page. \\ \\ Answers written on this page \\ will not be marked.};
    \end{tikzpicture}
    \newpage
}

% insert image in the middle
% usage: \insertimage[width=2cm]{fig/image-name}
\newcommand\insertimage[2][]{%
    \begin{center}%
        \includegraphics[#1]{#2}%
    \end{center}%
}
% insert framed image
% usage: \insertframedimage[width=2cm]{fig/image-name}
\newcommand\insertframedimage[2][]{%
    \fullwidth{%
        \setlength{\fboxsep}{1.5ex}%
        \fbox{\parbox[c]{\dimexpr\linewidth-2\fboxsep-2\fboxrule}{\centering\includegraphics[#1]{#2}}}%
    }%
}