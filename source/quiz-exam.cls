% quiz-exam.cls
% 
% for creating a simple, one or two page long maths quizzes 
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{quiz-exam}[2022/04/16 Simple quiz environment]

% use exam class ... for now
\LoadClass[11pt, addpoints]{exam}
\pagenumbering{arabic}

% load necessary packages
\RequirePackage{geometry}           % margin control
\RequirePackage{iftex}              % check if the document is compiled with XeTeX
\RequirePackage{paracol}            % for multiple column parts

% set the geometry of the paper - equal to "narrow" settings in Word
\geometry{
%    showframe,
    a4paper,
    includefoot,
    margin=1.27cm,
    footskip=1em
}

% length adjustments
\setlength\parindent{0pt}
\setlength{\parskip}{1em}

\renewcommand{\questionshook}{%
    \setlength{\leftmargin}{0.8cm}%
    \setlength{\labelsep}{1cm - \labelwidth}%
    \setlength{\listparindent}{0cm}%
    \setlength{\itemindent}{0cm}%
}
\renewcommand{\partshook}{%
    \setlength{\leftmargin}{1cm}%
    \setlength{\labelsep}{1.1cm - \labelwidth}%
    \setlength{\listparindent}{0cm}%
    \setlength{\itemindent}{0cm}%
}
\renewcommand{\subpartshook}{%
    \setlength{\leftmargin}{1cm}%
    \setlength{\labelsep}{1.1cm - \labelwidth}%
    \setlength{\listparindent}{0cm}%
    \setlength{\itemindent}{0cm}%
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
    \ClassWarning{quiz-exam}{XeTeX or LuaTeX not used. TX fonts will be loaded instead of Arial and TeX Gyre Termes.}
    \RequirePackage[utf8]{inputenc}
    \RequirePackage{newtxtext,newtxmath}
\fi

% settings for the exam class
\pointsdroppedatright
\bracketedpoints
\totalformat{[total: \totalpoints]}
\def\droppoints{%
  \hfill \padded@point@block%
}
\def\droptotalpoints{%
  \hfill \total@block \par%
}
\long\def\fullwidth#1{%
  \par
  \vbox{%
    % We entered internal vertical mode, and so we get \parshape=0.
    \leftskip=0pt \rightskip=0pt
    \advance\linewidth\@totalleftmargin
    \@totalleftmargin=0pt
    #1%
  }% vbox
  \nobreak
}
% put a lastpage reference before \end{questions}
% so that we can track the number of pages for the questions
\let\originalendquestions\endquestions
\def\endquestions{
    \label{lastpage}\originalendquestions
}

% settings for the paracol package
\globalcounter*

% set header and footer
\def\displaypagenum{%
    \ifthenelse{\pageref{lastpage}=1}{}{page \thepage\ of \pageref{lastpage}}%
}
\footer{}{}{\displaypagenum}

% modify maketitle 
\renewcommand\maketitle{%
    {%
    \begin{center}%
        Student name: \rule{7cm}{0.4pt} \hfill Marks: \rule{2cm}{0.4pt} / \numpoints%
    \end{center}%
    \begin{center}%
    {\LARGE \textbf \@title }\\[4ex] %
    \end{center}%
    }%
}%

% runs different code if a number is a multiple of another
% source: https://tex.stackexchange.com/questions/38743/checking-if-a-number-is-a-multiple-of-4
\newcommand{\doifmultipleof}[4]{%
  \ifnum\numexpr((#2)/(#1))*(#1)-(#2)=0%
    #3%
  \else%
    #4%
  \fi%
}

%%%%%%%%%%%%%%%%%% custom commands and environments

% a better fraction that follows IB style referencing
% usage: \tfrac{numerator}{denominator}
\renewcommand{\tfrac}[2]{\genfrac{}{}{}{1}{\textstyle{#1}}{\textstyle{#2}}}

% insert image in the middle
% usage: \insertimage[width=2cm]{fig/image-name}
\newcommand\insertimage[2][width=5cm]{%
    \begin{center}%
        \includegraphics[#1]{#2}%
    \end{center}%
}

% insert image on the right end 
% source: https://tex.stackexchange.com/questions/165691/placing-figures-adjacent-to-exam-choices
% usage: \insertimageonright[width=2cm]{fig/image-name}
\newcommand\insertimageonright[2][width=2cm]{%
    \hfill\makebox[0pt][r]{\raisebox{-\height}[0pt][0pt]{\includegraphics[#1]{#2}}}%
}

% parts divided in multiple columns
% usage: \begin{mcparts}[no-of-columns]
%            \part ...
%            \part ...
%        \end{mcparts}
\newenvironment{mcparts}[1][2]%
    {\begin{paracol}{#1}%
    \setlength{\columnsep}{0cm}%
    \begin{parts}%
    \NewCommandCopy{\originalpart}{\part}%
    \renewcommand{\part}{ \doifmultipleof{#1}{\arabic{partno}}{\switchcolumn*}{\switchcolumn} \originalpart }%
    \switchcolumn[\numexpr #1 - 1]%
    }%
    {\end{parts}%
    \end{paracol}%
}

% codes for a set of answer keys
% https://tex.stackexchange.com/questions/531780/printing-answers-with-the-exam-class-on-a-separate-page
\def\answers{Answer key}%DEFINE THE NAME OF THE ANSWER PAGE.
%SET THE BOX WHERE THE ANSWERS WILL BE STORED
\newbox\allanswers
\setbox\allanswers=\vbox{}

%ENVIRONMENT FOR ANSWERS
\newenvironment{answer}
{%
    \global\setbox\allanswers=\vbox\bgroup%BEGINS A VERTICAL BOX (1)
    \unvbox \allanswers\par%%%RECURSIVELY ADD NEW ANSWERS TO THE \vbox.
    \hspace{2em}\makebox[1pt][r]{\thequestion.\ }%%%%%%THIS PRINTS THE CURRENT QUESTION NUMBER AFTER ALL THE PREVIOUS QUESTOINS HAVE BEEN ADDED TO THE BOX; THE FIRST \mbox IS RIGHT-ALIGNED, SO IT PRINTS THE NUMBER ON THE CORRECT COLUMN. IF ABSENT, THE 1 OF A 13 WILL BE ON THE SAME COLUMN AS A 9.
    \mbox\bgroup%PUTS EVERYTHING INSIDE AN UNBREAKABLE BOX, FOR QUESTIONS ARRANGED ON COLUMNS, BECAUSE THE ANSWERS WILL BE THEN PRINTED THE SAME WAY; \bgroup BEGINS SUCH A BOX...(*)
}%
{%
    \egroup%(*)...\egroup ENDS IT.
    \medbreak%A BIT MORE OF SPACE BETWEEN ANSWER, SO YOU CAN USE \displaystyle IF NEEDED.
    \egroup%ENDS THE VERTICAL BOX (1)
}
%/ANSWERS

%PRINT ALL ANSWERS ON A SEPARATE PAGE
\newcommand{\showallanswers}{%
    \par\pagebreak%NEW PAGE FOR OUR ANSWERS
    \pagestyle{empty}%
    \makebox[\linewidth][c]{\hfill{\Large\bfseries\answers}\hfill}\par%CENTRED BOLDFACE TITLE FOR THE ANSWER KEY.
    \null\par%EXTRA SPACE FOR THE TITLE, OTHERWISE IT LOOKS VERY CRAMMED.
    \unvbox\allanswers}
%PRINTANSWERS