%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ib.cls
% 
% for creating an IB-style Maths exams
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ib}[2022/04/20 IB-style exam template]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASIS CLASS AND PACKAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use default article document as a basis
\LoadClass[11pt,twoside]{article}
\pagenumbering{arabic}

% load necessary packages
\RequirePackage{tikz}               % drawing figures
    \usetikzlibrary{calc}

\RequirePackage{geometry}           % margin control
% set the geometry of the paper
\geometry{
%    showframe,
    a4paper,
    asymmetric, % marginpar is always on the right
    vmargin={2.4cm, 2.5cm}, hmargin={1.5cm, 1.5cm},
    headsep=0.475cm,
    headheight=0.5cm,
    footskip=1cm,
    marginparwidth=0cm,
    marginparsep=0cm
}

\RequirePackage{enumitem}           % custom lists
\RequirePackage{globalvals}         % loading and saving global variables
\RequirePackage{fancyhdr}           % custom header and footer
\RequirePackage{iftex}              % check if the compiler can handle fontspec


% set default font to be Arial for text and TeX Gyre Termes for Maths
% this requires XeTeX or LuaTeX compilers
\iftutex
    \RequirePackage[no-math]{fontspec}
    \RequirePackage[
        warnings-off={mathtools-colon,mathtools-overbracket}
    ]{unicode-math}
    \defaultfontfeatures{ Ligatures=TeX }
    \setmainfont[Scale=1.00833333]{Arial}
    \setmathfont[Scale=MatchUppercase]{TeX Gyre Termes Math}
    \setmathrm[Scale=MatchUppercase]{TeX Gyre Termes Math}
% if LaTeX or pdfLaTeX are used, use TX fonts for text and Maths
\else
    \ClassWarning{quiz}{XeTeX or LuaTeX not used. TX fonts will be loaded instead of Arial and TeX Gyre Termes.}
    \RequirePackage[utf8]{inputenc}
    \RequirePackage{newtxtext,newtxmath}
\fi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MACROS FOR LOCAL USE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% writes a value and its name to .aux file
\newcommand{\@toaux}[2]{%
    \immediate\write\@auxout{%
        \string\global\string\@namedef{exam@#1}{#2}%
    }%
}
% reads a value from .aux file
\newcommand{\@fromaux}[1]{%
    \ifcsname exam@#1\endcsname%
        \csname exam@#1\endcsname%
    \else%
        {\mbox{\normalfont ??}}%
    \fi%
}

% checks if #1 is a number
\def\isnum#1#2#3{%
    \if!\ifnum9<1#1!\else_\fi%
    #2 \else #3 \fi%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LENGTHS AND FULLWIDTH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% length adjustments
\setlength{\parindent}{0pt}
\setlength{\parskip}{1.3ex}
\linespread{0.97}

% fullwidth
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COUNTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% counters for tracking parts of the exam
%\newcounter{questionsi}                % question number is set by enumitem
\def\thequestion{\arabic{questionsi}}   % so just add a macro to access it

% counters for tracking points
\newcounter{exampoints}                 % total points of the exam so far
\newcounter{questionpoints}             % total points of the question so far

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FETCHING TOTALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% page number of the last page
\newcommand\totalpages{\@fromaux{lastpage}}
% total number of questions
\newcommand\totalquestions{\@fromaux{totalquestions}}
% total number of points for the entire exam
\newcommand\totalpoints{\@fromaux{totalpoints}}
% total number of points for a specific question
\newcommand\totalquestionpoints[1]{\@fromaux{points@q#1}}
\newcommand\thisquestionpoints{\totalquestionpoints{\thequestion}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WRITING TOTALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the total points of the current question
\def\recordquestionpoints{\@toaux{points@q\arabic{questionsi}}{\thequestionpoints}}


\AtEndDocument{% update the points one last time
    \@toaux{totalpoints}{\theexampoints}% the total points for the entire exam
    \@toaux{totalquestions}{\thequestion}% total number of questions
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINTING AND UPDATING POINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \print@points prints the given points on the right margin.
\def\print@points#1{%
    \marginpar{\llap{[#1]}}%
}
% \print@question@points prints the total points in the question.
\def\print@question@points{%
    [Maximum mark:~\thisquestionpoints]%
    \par%
}

% \points[int] increases the points of the current question by int and call \print@points.
% \points*[int] increases the points by int, but does not print the points.
\newcommand*{\points}{ \@ifstar\update@points\update@print@points }
\newcommand\update@points[1]{%
    \addtocounter{questionpoints}{#1}%
}
\newcommand\update@print@points[1]{%
    \update@points{#1}%
    \print@points{#1}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% QUESTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% questions environment
\newlist{questions}{enumerate}{1}
\setlist[questions]{
    before=\questions@start,
    after=\questions@end,
    label=\textbf{\arabic*.},
    align=left,
    leftmargin=1cm,
    labelwidth=!,
    labelindent=0cm,
    rightmargin=1.2cm,
    listparindent=0cm,
    itemsep=0cm,
    parsep=2.3ex,
    topsep=0.55ex
}
% set of codes to execute right after \begin{questions}
\def\questions@start{%
    % record the current question number to see if we need to update the points
    \edef\thefirstquestion{\thequestion}%
}
% set of codes to execute just before \end{questions}
\def\questions@end{%
    \restartlist{parts}%
    \restartlist{subparts}%
    \recordquestionpoints% record and update the points of the last question
    \update@question@points% move the points of the last question
    \@toaux{lastpage}{\thepage}% number of pages
}

% \question adds a list and performs operations on the points from the previous question
\def\question{%
    \ifnum\thequestion=\thefirstquestion \else% if this is NOT the first question
        \recordquestionpoints% record the total points of the previous question
        \update@question@points% move previous question's points to total exam points
    \fi%
    \restartlist{parts}% reset the part reference to (a)
    \item%
    \hspace{0cm}\print@question@points\ignorespaces%
}
% update the points accumulated in the previous question
\def\update@question@points{%
    \addtocounter{exampoints}{\value{questionpoints}}%
    \setcounter{questionpoints}{0}%
}
% parts environment
\newlist{parts}{enumerate}{1}
\setlist[parts]{
    resume,
    label=(\alph*),
    align=left,
    leftmargin=1cm,
    labelwidth=!,
    labelindent=0cm,
    rightmargin=0cm,
    listparindent=0cm,
    itemsep=0cm,
    parsep=2.3ex,
    topsep=0cm,
    partopsep=0cm
}
\def\part{%
    \restartlist{subparts}\item%
}

% subparts environment
\newlist{subparts}{enumerate}{1}
\setlist[subparts]{
    label=(\roman*),
    align=left,
    leftmargin=1cm,
    labelwidth=!,
    labelindent=0cm,
    rightmargin=0cm,
    listparindent=0cm,
    itemsep=0cm,
    parsep=2.3ex,
    topsep=0cm,
    partopsep=0cm
}
\def\subpart{%
    \item%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BACKGROUNDS, HEADERS AND FOOTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
\def\toplogo{ source/graphics/iblogo_1 }
\def\botlogo{ source/graphics/iblogo_2 }
\def\schoollogo{ source/graphics/schoollogo }
\def\logos{
\if@useiblogos
    \begin{tikzpicture}[remember picture, overlay]% top IB logo
        \node[anchor=north east,inner sep=0pt] at ($ (current page.north east)+(-1.95,-0.95) $) {\includegraphics{\toplogo}};
    \end{tikzpicture}
    \begin{tikzpicture}[remember picture, overlay]% bottom IB logo
        \node[anchor=south east,inner sep=0pt] at (current page.south east) {\includegraphics{\botlogo}};
    \end{tikzpicture}
\else
    \begin{tikzpicture}[remember picture, overlay]% school logo
        \node[anchor=north east,inner sep=0pt] at ($ (current page.north east)+(-2,-1) $)
            {\includegraphics[height=4.25cm]{\schoollogo}};
    \end{tikzpicture}
\fi
}

% headers and footers
\def\plainfooterRO{%
    \ifnum\thepage<\totalpages%
        \textbf{Turn over}%
    \else\ifnum\thepage=\totalpages%
        \textbf{END OF EXAM}%
    \fi\fi%
}
\def\plainfooterRE{%
    \ifnum\thepage=\totalpages%
        \textbf{END OF EXAM}%
    \fi%
}
\def\plainheader{%
    \ifnum\thepage>\totalpages%
        \text{}%
    \else%
        \text{-- \thepage\ --}%
    \fi%
}
\fancypagestyle{titlepage}{% page 1
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \renewcommand{\footrulewidth}{0pt}
    \renewcommand{\headruleskip}{0pt}
    \renewcommand{\footruleskip}{0pt}
    \fancyheadoffset{0.5cm}
    \fancyfoot[LO]{\pageborder\leftbinding\logos}
    \fancyfoot[LE]{\pageborder\rightbinding}
}
\fancypagestyle{plain}{% rest of the pages
    \fancyhead[C]{\mbox{\plainheader}}
    \fancyfoot[LO]{\pageborder\leftbinding}
    \fancyfoot[RO]{\mbox{\plainfooterRO}}
    \fancyfoot[RE]{\mbox{\plainfooterRE}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GRADE TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \@gradetabletrue then draw the grade table
\newif\if@gradetable
\@gradetablefalse
% include \drawgradetable in the preamble to draw a grade table on the front page.
\newcommand\drawgradetable[1][8]{%
    \gdef\q@per@row{#1}%
    \@gradetabletrue
}
% if we fail to read the total number of questions from the .aux file,
% the table cannot be drawn and the code will crash
% (preventing the total number of questions to be recorded and so on)

% \ifnum\totalquestions>0\relax
%     \ClassInfo{ib}{tq-yes!}
% \else
%     \ClassInfo{ib}{tq-no!}
% \fi

% \ifcsname exam@totalquestions\endcsname%
%     \ClassInfo{ib}{\protect\totalquestions loaded! Will print grade table in \protect\maketitle. \MessageBreak}%
% \else%
%     \@gradetablefalse%
%     \ClassWarning{ib}{\protect\totalquestions\ not loaded! The total number of questions is unavailable from the .aux file. Compile LaTeX once again to draw the grade table. \MessageBreak}%
% \fi


\newcommand\gradetable{%
    % define counters for looping
    \newcounter{@q@drawn}  % track the last q drawn in the previous loop
    \newcounter{@q@todraw} % track the last q to be drawn in the current loop
    \newcounter{@col} % column iterator for loops
    \newcounter{@q}   % question iterator for loops
    
    % the code is written to have exactly
    \setcounter{@q@todraw}{\q@per@row}
    \@whilenum{\value{@q@todraw}<\totalquestions}\do{
        \make@table@middle[\arabic{@q@drawn}]{\arabic{@q@todraw}}
        \setcounter{@q@drawn}{\value{@q@todraw}}
        \addtocounter{@q@todraw}{\q@per@row}
    }
    \make@table[\arabic{@q@drawn}]{\totalquestions}
    \par%
}

% create a table
% note: https://tex.stackexchange.com/questions/193327/strange-extra-line-after-forloop-in-a-tabular-table

% \make@table[Qstart]{Qend} draws a grading table
% from Qstart+1 to Qend
% then it attaches a "total" box at the end
% the total box is "right-flushed" for better organisation when more than 8 questions are drawn
\newcommand\make@table[2][0]{%
    \renewcommand\arraystretch{1.5}%
    \def\numcols{\the\numexpr#2-#1\relax}%
    \def\numcols@pone{\the\numexpr#2-#1+1\relax}%
    \def\numcols@pthree{\the\numexpr#2-#1+3\relax}%
    % the extra space needed to flush the total box to the right is 
    %   cell content widths + column separations + border widths
    \def\hspace@to@last{%
    \dimexpr (3em)*(\q@per@row-\numcols)%
            +\tabcolsep*(2*\q@per@row-2*\numcols)%
            +\arrayrulewidth*(\q@per@row-\numcols) \relax%
    }%
    \begin{tabular}{|l| *{\numcols}{c|} p{\hspace@to@last} |c|}
    \cline{1-\numcols@pone} \cline{\numcols@pthree-\numcols@pthree}
        \hfill Q:&\make@cell@q[#1]{#2}&&\textbf{Total} \\
    \cline{1-\numcols@pone} \cline{\numcols@pthree-\numcols@pthree}
        \parbox[c][3.5em][c]{3em}{\hfill Marks:}&%
        \make@cell@marks[#1]{#2}&&%
        \relax\parbox[c][3em][b]{4em}{\hfill \textbf{/\totalpoints}} \\
    \cline{1-\numcols@pone} \cline{\numcols@pthree-\numcols@pthree}
    \end{tabular}%
    \par
}
% \make@table@middle[Qstart]{Qend} draws a grading table
% from Qstart+1 to Qend
% without a "total" box at the end
\newcommand\make@table@middle[2][0]{%
    \renewcommand\arraystretch{1.5}%
    \def\numcols{%
        \the\numexpr#2-#1\relax%
    }%
    \begin{tabular}{|l| *{\numcols}{c|}}
    \hline
        \hfill Q:&\make@cell@q[#1]{#2}\\
    \hline
        \parbox[c][3.5em][c]{3em}{\hfill Marks:}&%
        \make@cell@marks[#1]{#2}\\
    \hline
    \end{tabular}%
    \par
}

% use recursion to print cells
% \make@cell@q[#1=0]{#2}
% source: https://tex.stackexchange.com/questions/361483/issue-with-loop-to-create-contents-of-tabular-row
\def\amph{&}% putting & directly into a conditional cause it to break
\newcommand\make@cell@q[2][0]{%
    \ifnum#1>0\setcounter{@q}{#1}\fi%
    \stepcounter{@q}\arabic{@q}
    \ifnum\numexpr#2>\value{@q}%
        \amph\make@cell@q{#2}%
    \else%
        \setcounter{@q}{0}%
    \fi%
}
\newcommand\make@cell@marks[2][0]{%
    \ifnum#1>0\setcounter{@q}{#1}\fi%
    \stepcounter{@q}\parbox[c][3em][b]{3em}{\hfill/\totalquestionpoints{\the@q}}
    \ifnum\numexpr#2>\value{@q}%
        \amph\make@cell@marks{#2}%
    \else%
        \setcounter{@q}{0}%
    \fi%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TITLE PAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% place to hold the length of test
\newcommand\testlength[1]{ \gdef\@testlength{#1} }

% instructions environment
\newbox\@instructions% place to hold the instructions
\def\instructions@before{%
    \global\setbox\@instructions=\vbox\bgroup%
}
\def\instructions@after{%
    \egroup%
}
\newlist{instructions}{itemize}{1}
\setlist[instructions]{
    label={\raisebox{-0.2\height}{\Large\textbullet}},
    left=0pt,
    labelsep=0.82em,
    rightmargin=2cm,
    nosep,
    before={\instructions@before},
    after={\instructions@after}
}

% include \numberbox in the preamble to include space for candidate number (IB default for Paper 1)
% include \namebox in the preamble to include space for student name
% default: no space for identification (IB default for Paper 2 & 3)
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

% modify maketitle
\renewcommand\maketitle{%
    \newgeometry{vmargin={2.9cm, 2.5cm}, hmargin={2cm, 2cm}, nomarginpar}%
    \pagestyle{titlepage}
    \begin{flushleft} \fontsize{12.94086}{15.529032}\selectfont \textbf \@title \\[4ex] \end{flushleft}% title is 13pt
    \begin{tabular*}{\linewidth}{@{} l @{\extracolsep{\fill}} r @{}}%
        \parbox[b][8ex]{0.45\linewidth}{ \@date \vfill \@testlength } & %
        \ifnumberbox\sessionnumberinput\else\ifnamebox\nameinput\fi\fi%
    \end{tabular*}%
    \par\vspace{0.1cm}%
    \rule{\textwidth}{0.8pt}\par%
    \textbf{Instructions to candidates}\par%
    \unvbox\@instructions%
    \vfill%
    \isnum{\totalquestions}%
        {\ClassInfo{ib}{Grade table available!}}%
        {\@gradetablefalse\ClassWarning{ib}{Run LaTeX again to make the grade table.}}%
    \if@gradetable%
        \gradetable%
    \fi%
    \vspace{1cm}%
    \hspace{2.3em} \totalpages\ pages%
    \newpage%
    \restoregeometry%
    \pagestyle{plain}
}%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ANSWER BOX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make answer box
% \makeanswerbox[3cm] gives an answer box 3cm tall
% \makeanswerbox fills the rest of the page
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MISCELLANEOUS COMMANDS AND ENVIRONMENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a better fraction that follows IB style
% usage: \tfrac{numerator}{denominator}
\renewcommand{\tfrac}[2]{\genfrac{}{}{}{1}{\textstyle{#1}}{\textstyle{#2}}}

% insert (continue on the following page) and (continued)
\def\continue{%
    \par
    \fullwidth{ \textbf{(This question continues on the following page)} }
    \newpage
    \fullwidth{ \textbf{(Question \thequestion\ continued)} } \par%
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

% insert \donotwrite until the number of pages is a multiple of four
\newcounter{i@page} % iterator for the page number
\def\fillbooklet{%
    \setcounter{i@page}{\thepage}% i@page now equals to where \end{questions} is located
    % if i@page is not a multiple of four
    \loop\ifnum\numexpr(\value{i@page}/4)*4-\value{i@page}=0\else
        % add a new blank page and repeat
        \newpage
        \donotwrite
        \stepcounter{i@page}
    \repeat
}