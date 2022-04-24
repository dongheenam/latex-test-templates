% quiz.cls
% 
% for creating a simple, one or two page long maths quizzes 
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{quiz}[2022/04/20 Simple quiz environment]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASIS CLASS AND PACKAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use default article document as a basis
\LoadClass[11pt]{article}
\pagenumbering{arabic}

% load necessary packages
\RequirePackage{tikz}               % drawing figures
    \usetikzlibrary{calc}

\RequirePackage{geometry}           % margin control
% set the geometry of the paper
\geometry{
%    showframe,
    a4paper,
    nohead,
    includefoot,
    margin=1.27cm,
    footskip=1em,
    marginparwidth=0cm,
    marginparsep=0cm
}

\RequirePackage[inline]{enumitem}   % custom lists
\RequirePackage{fancyhdr}           % custom header and footer
\RequirePackage{iftex}              % check if the compiler can handle fontspec
\RequirePackage{paracol}            % for multiple column parts

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
    \ClassWarning{quiz}{XeLaTeX or LuaLaTeX not used. TX fonts will be loaded instead of Arial and TeX Gyre Termes.}
    \RequirePackage[utf8]{inputenc}
    \RequirePackage{newtxtext,newtxmath}
\fi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MACROS FOR LOCAL USE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% runs different code if a number is a multiple of another
% source: https://tex.stackexchange.com/questions/38743/checking-if-a-number-is-a-multiple-of-4
\newcommand{\do@ifmultipleof}[4]{%
    \ifnum\numexpr((#2)/(#1))*(#1)-(#2)=0%
        #3%
    \else%
        #4%
    \fi%
}

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LENGTHS AND FULLWIDTH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% length adjustments
\setlength\parindent{0pt}
\setlength{\parskip}{1em}

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
\newcounter{examsection}                % test section number, default output is \Alph
\setcounter{examsection}{0}
%\newcounter{questionsi}                % question number is set by enumitem
\def\thequestion{\arabic{questionsi}}   % so just add a macro to access it 
\newcounter{noquestions}                % count the number of questions
                                        % equivalent to questionsi if \sectionresetsquestion is not set

% counters for tracking points
\newcounter{exampoints}                 % total points of the exam so far
\newcounter{sectionpoints}          % total points of the test section so far
\newcounter{questionpoints}             % total points of the question so far

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FETCHING TOTALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% page number of the last page
\newcommand\totalpages{\@fromaux{lastpage}}
% total number of questions
\newcommand\totalquestions{\@fromaux{totalquestions}}
% total number of points for the entire exam
\newcommand\totalpoints{\@fromaux{totalpoints}}
% total number of points for a specific section
\newcommand\totalsectionpoints[1]{\@fromaux{points@sec#1}}
\newcommand\thissectionpoints{\totalsectionpoints{\theexamsection}}
% total number of points for a specific question
\newcommand\totalquestionpoints[2][\theexamsection]{\@fromaux{points@sec#1@q#2}}
\newcommand\thisquestionpoints{\totalquestionpoints{\thequestion}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WRITING TOTALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\AtEndDocument{% update the points one last time
    \update@section@points% record and update the points for the last section
    \@toaux{totalpoints}{\theexampoints}% record the total points for the entire exam
    \@toaux{totalquestions}{\thenoquestions}% record the total number of questions
    \ifshowanswers \else% \showanswers records the last page instead
        \@toaux{lastpage}{\thepage}% reference for the last page
    \fi%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINTING AND UPDATING POINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \print@points prints the given points on the right margin.
\def\print@points#1{%
    \marginpar{\llap{[#1]}}%
}
% \print@question@points prints the total points in the question.
\def\print@question@points{%
    \marginpar{\llap{[total:~\thisquestionpoints]}}%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ANSWERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% true if \showanswers is seen in the document
% used to exclude answers to be counted towards \totalpages
\newif\ifshowanswers
\showanswersfalse

% codes for a set of answer keys
% https://tex.stackexchange.com/questions/531780/printing-answers-with-the-exam-class-on-a-separate-page
\def\answerstitle{Answer key}%DEFINE THE NAME OF THE ANSWER PAGE.
%SET THE BOX WHERE THE ANSWERS WILL BE STORED
\newbox\allanswers
\setbox\allanswers=\vbox{}

% environment to put answers in
\newenvironment{answer}
{%
    \def\@currentpart{\value{partsi}}% record the current part number
    \restartlist{parts}%
    \global\setbox\allanswers=\vbox\bgroup%BEGINS A VERTICAL BOX (1)
    \unvbox \allanswers\par%%%RECURSIVELY ADD NEW ANSWERS TO THE \vbox.
    \makebox[1cm][l]{\textbf{\thequestion.}}%%%%%%THIS PRINTS THE CURRENT QUESTION NUMBER AFTER ALL THE PREVIOUS QUESTOINS HAVE BEEN ADDED TO THE BOX; THE FIRST \mbox IS RIGHT-ALIGNED, SO IT PRINTS THE NUMBER ON THE CORRECT COLUMN. IF ABSENT, THE 1 OF A 13 WILL BE ON THE SAME COLUMN AS A 9.
    \begin{minipage}[t]{\dimexpr \textwidth-2cm \relax}%PUTS EVERYTHING INSIDE A MINIPAGE...(*)
}%
{%
    \end{minipage}%
    \smallskip%
    \egroup%ENDS THE VERTICAL BOX (1)
    \setcounter{partsi}{\@currentpart}%
}
%/ANSWERS

%PRINT ALL ANSWERS ON A SEPARATE PAGE
\newcommand{\showallanswers}{%
    \showanswerstrue% turn off recording the number of pages at the end of the document
    \@toaux{lastpage}{\thepage}% record the number of pages here, before the pagebreak
    \par\pagebreak%NEW PAGE FOR OUR ANSWERS
    \pagestyle{empty}%
    \makebox[\linewidth][c]{\hfill{\Large\bfseries\answerstitle}\hfill}\par%CENTRED BOLDFACE TITLE FOR THE ANSWER KEY.
    \null\par%EXTRA SPACE FOR THE TITLE, OTHERWISE IT LOOKS VERY CRAMMED.
    \unvbox\allanswers}
%PRINTANSWERS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SECTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if true then every new section starts with Q1
% if false then the question numbers carry on
\newif\ifresetqno
\resetqnofalse
\def\sectionresetsquestion{ \resetqnotrue }

% update the points accumulated in the previous section
\def\update@section@points{%
    \@toaux{points@sec\arabic{examsection}}{\thesectionpoints}%
    \addtocounter{exampoints}{\value{sectionpoints}}%
    \setcounter{sectionpoints}{0}%
}
% print the section number and title
\def\write@examsection#1{
    \par\bigskip%
    \underline{\smash{\large\bfseries SECTION \Alph{examsection}.~#1}}%
    \par\smallskip%
}
% define a new section to divide the exam into different parts
\newcommand{\examsection}[1]{%
    \ifnum\theexamsection=0 \else% if this is NOT the first section
        \update@section@points% update exampoints, record and reset sectionpoints
    \fi%
    \ifresetqno% reset the question counter if requested
        \restartlist{questions}%
    \fi%
    \stepcounter{examsection}%
    % writes the section title to the Answers box
    \global\setbox\allanswers=\vbox{%
        \unvbox \allanswers%
        \write@examsection{#1}%
    }%
    % writes the section title to the document
    \write@examsection{#1}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% QUESTIONS, PARTS, SUBPARTS, CHOICES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% questions
% the questions environment
\newlist{questions}{enumerate}{1}
\setlist[questions]{
    resume,
    first=\questions@start,
    after=\questions@end,
    label=\textbf{\arabic*.},
    align=left,
    leftmargin=1cm,
    labelwidth=!,
    labelindent=0cm,
    rightmargin=1.5cm,
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
    \update@question@points% record and update the points for the last question
}

% \question adds a list and performs operations on the points from the previous question
% \question* is the same as \question, but shows the total points of the question at the right margin
\newcommand{\question}{\@ifstar{\@question@star}{\@question}}
\def\@question{%
    \ifnum\thequestion=\thefirstquestion \else% if this is NOT the first question
        \update@question@points% update sectionpoints, record and reset questionpoints
    \fi%
    \stepcounter{noquestions}% increase the number of questions by 1
    \restartlist{parts}% reset the part reference to (a)
    \item%
}
\def\@question@star{%
    \@question%
    \hspace{0cm}\print@question@points\ignorespaces%
}
% update the points accumulated in the previous question
\def\update@question@points{%
    \@toaux{points@sec\arabic{examsection}@q\arabic{questionsi}}{\thequestionpoints}%
    \addtocounter{sectionpoints}{\value{questionpoints}}%
    \setcounter{questionpoints}{0}%
}

%% parts environment
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
% part
\def\part{%
    \restartlist{subparts}\item%
}

% parts divided in multiple columns
\newcommand\update@print@points@mcparts[1]{%
    \update@points{#1}%
    \hspace*{\fill}\mbox{[#1]}%
    \par%
}
\newenvironment{mcparts}[1][2]{%
    \renewcommand*{\points}{ \@ifstar\update@points\update@print@points@mcparts }
    \setlength{\columnsep}{0pt}%
    \begin{paracol}{#1}%
    \begin{parts}%
    \NewCommandCopy{\originalpart}{\part}%
    \renewcommand{\part}{ \do@ifmultipleof{#1}{\arabic{partsi}}{\switchcolumn*}{\switchcolumn} \originalpart }%
    \switchcolumn[\numexpr #1 - 1]%
    }%
    {\end{parts}%
    \end{paracol}%
}

%% subparts environment
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
% subpart
\def\subpart{%
    \item%
}

%% choices environment
\newlist{choices}{enumerate}{1}
\setlist[choices]{
    label=\Alph*.,
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
% choices* gives inline list instead
\newlist{choices*}{enumerate*}{1}
\setlist[choices*]{
    label=\Alph*.,
    itemjoin=\hspace{0cm plus 1fil}
}
% choice
\def\choice{%
    \item%
}

% continue counting in paracols
\globalcounter*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HEADERS AND FOOTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set header and footer
\def\plainfooterR{%
    \ifnum\thepage<\totalpages%
        {page \thepage\ of \totalpages}%
    \else%
        \textbf{END OF QUIZ}%
    \fi%
}
\fancypagestyle{plain}{
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \renewcommand{\footrulewidth}{0pt}
    \renewcommand{\headruleskip}{0pt}
    \renewcommand{\footruleskip}{0pt}
    \fancyfoot[R]{\mbox{\plainfooterR}}
}
\pagestyle{plain}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TITLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modify maketitle 
\renewcommand\maketitle{%
    {%
    \begin{center}%
        Student name: \rule{7cm}{0.4pt} \hfill Marks: \rule{2cm}{0.4pt} / \totalpoints%
    \end{center}%
    \begin{center}%
    {\LARGE \textbf \@title }\\[4ex] %
    \end{center}%
    }%
}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MISCELLANEOUS COMMANDS AND ENVIRONMENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


