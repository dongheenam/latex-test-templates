%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hsc.cls
% 
% for creating an HSC-style Maths exams
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hsc}[2022/08/21 HSC-style exam template]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASIS CLASS AND PACKAGES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use default article document as a basis
\LoadClass[12pt,twoside]{article}
\pagenumbering{arabic}

% load necessary packages
\RequirePackage{tikz}               % drawing figures
\usetikzlibrary{calc}

\RequirePackage{geometry}           % margin control
% base geometry
\geometry{
    % showframe,
    a4paper,
    asymmetric, % marginpar is always on the right
    nohead,
    nomarginpar,
    vmargin={2.35cm, 2.35cm}, hmargin={2.5cm, 2.5cm},
    footskip=1cm
    % marginparwidth=0cm,
    % marginparsep=0cm
}

\RequirePackage{amsmath,mathtools}  % useful macros and shortcuts
\RequirePackage{enumitem}           % custom lists
\RequirePackage{fancyhdr}           % custom header and footer
\RequirePackage{paracol}            % multiple columns

% set default font to be Arial for text and TeX Gyre Termes for Maths
% this requires XeTeX or LuaTeX compilers
\iftutex
    \RequirePackage[no-math]{fontspec}
    \defaultfontfeatures{ Ligatures=TeX }
    % for 12pt font, only conversion we need is 1 bp = 1.00374 pt
    \setmainfont[Scale=1.00374]{Times New Roman}
    \setsansfont[Scale=1.00374]{Arial}
    \RequirePackage[
        warnings-off={mathtools-colon,mathtools-overbracket}
    ]{unicode-math}
    \setmathfont[Scale=1.00374]{STIX Two Math}
    % load latin and greek symbols from TeX Gyre instead
    \setmathfont[Scale=1, 
        range={up/{latin,Latin,greek,Greek},it/{latin,Latin,greek,Greek}, 
        bfup/{latin,Latin,greek,Greek},bfit/{latin,Latin,greek,Greek}}
    ]{TeX Gyre Termes Math}
    \setmathrm[Scale=1.00374]{Times New Roman}
% if LaTeX or pdfLaTeX are used, use TX fonts for text and Maths
\else
    \ClassWarning{quiz}{XeTeX or LuaTeX not used. TX fonts will be loaded instead of Arial and TeX Gyre Termes.}
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
        {\mbox{\normalfont ??}\ClassWarning{ib}{Variable #1 not defected from .aux file. Run LaTeX once again}}%
    \fi%
}

% checks if #1 is a number
% source: https://tex.stackexchange.com/questions/7180/testing-for-number
\def\isnum#1#2#3{%
    \if!\ifnum9<1#1!\else_\fi%
    #2 \else #3 \fi%
}

% write text with specified font size
% \size{12}{Hello} prints Hello with font size of 12pt
\def\scaledfontsize#1{%
    \the\dimexpr #1pt / 1.00374\relax%
}
\newcommand\size[2]{{\fontsize{#1}{#1}\selectfont#2}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LENGTHS AND FULLWIDTH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% length adjustments
\setlength{\parindent}{0pt}
\setlength{\parskip}{0.5cm}
\setlength{\columnsep}{0cm}% paracol
% \setlength{\columnseprule}{0.4pt}% paracol
\linespread{0.97}

% fullwidth
\long\def\fullwidth#1{%
  \par
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
% write the total points of the current question
\def\recordquestionpoints{\@toaux{points@q\thequestion}{\thequestionpoints}}

\AtEndDocument{% update the points one last time
    \update@section@points% record and update the points for the last section
    \@toaux{totalpoints}{\theexampoints}% the total points for the entire exam
    \@toaux{totalquestions}{\thequestion}% total number of questions
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINTING AND UPDATING POINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \print@points prints the given points on the right margin.
\def\print@points#1{%
    \hspace{0cm}\marginpar{\hfill\textbf{#1}}\ignorespaces%
}
% \print@question@points prints the total points in the question.
\def\print@question@points{%
    \hspace{0cm}({\thisquestionpoints} marks)%
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SECTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set of codes to execute when a new section is made
\def\do@examsection{%
    \ifnum\theexamsection=0 \else% if this is NOT the first section
        \update@section@points% update exampoints, record and reset sectionpoints
    \fi%
    \stepcounter{examsection}%
}
% update the points accumulated in the previous section
\def\update@section@points{%
    \@toaux{points@sec\arabic{examsection}}{\thesectionpoints}%
    \addtocounter{exampoints}{\value{sectionpoints}}%
    \setcounter{sectionpoints}{0}%
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% QUESTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% recognises multiple choice environment
\newif\if@mcq
\@mcqfalse

% questions environment
\newlist{questions}{enumerate}{1}
\setlist[questions]{
    resume=q_series,
    before=\questions@start,
    after=\questions@end,
    label=\textbf{Question \arabic*},
    ref=\arabic*,
    align=left,
    leftmargin=0cm,
    labelwidth=!,
    itemindent=!,
    listparindent=0cm,
    rightmargin=0cm,
    itemsep=0.5cm,
    parsep=0.5cm,
    topsep=-0.1cm
}
% mcq environment
\newenvironment{mcquestions}{
    \@mcqtrue
    \begin{questions}[
        resume=q_series,
        label=\textbf{\arabic*},
        ref=\arabic*,
        leftmargin=1cm,
        labelindent=0cm
    ]
}{
    \end{questions}
    \@mcqfalse
}
% set of codes to execute right after \begin{questions}
\def\questions@start{%
    % record the current question number to see if we need to update the points
    \edef\thefirstquestion{\thequestion}%
}
% set of codes to execute just before \end{questions}
\def\questions@end{%
    \restartlist{parts}%
    \update@question@points% record and update the points for the last question
}

% \question adds a list and performs operations on the points from the previous question
\def\question{%
    \ifnum\thequestion=\thefirstquestion \else% if this is NOT the first question
        \recordquestionpoints% record the total points of the previous question
        \update@question@points% move previous question's points to total exam points
    \fi%
    \restartlist{parts}% reset the part reference to (a)
    \if@mcq% multiple choice questions have 1 point
        \addtocounter{questionpoints}{1}%
        \item%
    \else% short answer questions have 
        \item%
        \hspace{0cm}\print@question@points\par\ignorespaces%
    \fi%
}
% update the points accumulated in the previous question
\def\update@question@points{%
    \@toaux{points@sec\arabic{examsection}@q\arabic{questionsi}}{\thequestionpoints}%
    \addtocounter{sectionpoints}{\value{questionpoints}}%
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
    itemsep=0.5cm,
    parsep=0.5cm,
    topsep=0.5cm
}
\def\part{%
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
    itemsep=0.25cm,
    parsep=0ex,
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

%% custom choice environments
\newcounter{my@choice}
\globalcounter*% prevent resetting part and subpart labels inside paracols

% choices given as a table
\newenvironment{tabularchoices}[1]{%
    \setcounter{my@choice}{0}%
    \begin{tabular}{#1}%
    \renewcommand{\choice}{%
        \stepcounter{my@choice}%
        \makebox[1cm][l]{\Alph{my@choice}.}\ignorespaces%
    }%
}{%
    \end{tabular}%
}
% choices with 2 columns
\newenvironment{multicolchoices}{
    \begin{paracol}{2}%
    \setcounter{my@choice}{0}%
    \renewcommand{\choice}{%
        \do@ifmultipleof{2}{\themy@choice}{\switchcolumn*}{\switchcolumn}%
        \stepcounter{my@choice}%
        \makebox[1cm][l]{\Alph{my@choice}.}\ignorespaces%
    }%
    \switchcolumn[1]%
}{%
    \end{paracol}%
}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BACKGROUNDS, HEADERS AND FOOTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\graphicspath{{source/graphics/}}

% student number field
\def\numberbox{%
    \sffamily
    \begin{tikzpicture}[remember picture, overlay]
        \begin{scope}[shift=(current page.north east), xshift=-1.6cm, yshift=-1.25cm]
            \draw[line width=0.6pt] (0,0) rectangle (-6.9, -1);
            \node[anchor=north east, inner xsep=0cm] at (0, -1) {Student Number};
            \foreach \x in {1, ..., 8} {
                \draw[line width=0.6pt] (-\x*6.9/9, 0) -- ++(0, -1);
            }
        \end{scope}
    \end{tikzpicture}%
}

% base, page 1
\fancypagestyle{plain}{
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \renewcommand{\footrulewidth}{0pt}
    \renewcommand{\headruleskip}{0pt}
    \renewcommand{\footruleskip}{0pt}
    \fancyheadoffset{0.5cm}
}
% section 1
\fancypagestyle{sectionone}{
    \fancyfootoffset[r]{0cm}
    \fancyfoot[C]{-- {\thepage} --}
}
% section 2
\fancypagestyle{sectiontwo}{
    \fancyfoot[C]{-- {\thepage} --}
    \fancyfoot[RO]{\numberbox}
    \fancyfootoffset[R]{0cm}
}
\fancypagestyle{sectiontwobody}{
    \fancyfootoffset[R]{1.5cm}
}
\pagestyle{plain}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TITLE PAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% title information
\newcommand\schoolname[1]{\gdef\@schoolname{#1}}
\newcommand\examyear[1]{\gdef\@examyear{#1}}
\newcommand\examtitle[1]{\gdef\@examtitle{#1}}
\newcommand\examsubject[1]{\gdef\@examsubject{#1}}
% macro for time setups
\newcommand\readingtime[1]{\gdef\putreadingtime{#1}}
\newcommand\workingtime[1]{\gdef\putworkingtime{#1}}
\newcommand\sectiononetime[1]{\gdef\putsectiononetime{#1}}
\newcommand\sectiontwotime[1]{\gdef\putsectiontwotime{#1}}

% blocks for information
\newcommand\sectiononeinfo[1]{\gdef\@sectiononeinfo{#1}}
\newcommand\sectiontwoinfo[1]{\gdef\@sectiontwoinfo{#1}}

% information box
\newenvironment{infobox}[1]{%
    \rule{2.9cm}{0.5pt}
    \begin{minipage}[t]{3.1cm}
        \raggedright
        \textbf{#1}      
    \end{minipage}%
    \begin{minipage}[t]{12.7cm}%
        \raggedright%
        \setlength{\parskip}{1ex}%
}{%
    \end{minipage}%
    \vspace{0.45cm}
}

% list environment inside information box
\newlist{infoitems}{itemize}{1}
\setlist[infoitems]{
    label={\textbullet},
    left=0pt,
    labelsep=0.2cm,
    rightmargin=0cm,
    itemsep=0.13cm,
    topsep=0cm,
    parsep=0cm,
}

% title for Section 1
\newcommand\sectiononetitle{%
    \sffamily%
    \raggedright%
    \includegraphics[height=2.65cm]{schoollogo}\par%
    \size{13}{\@schoolname}\par%
    \vspace{2.5cm}%
    {
        \setlength{\fboxrule}{0.7pt}
        \setlength{\fboxsep}{0.15cm}
        \fbox{\size{16}{\textbf{\@examyear}}}
        \hspace{0.05cm}\size{10}{\textbf{\uppercase{\@examtitle}}} \par%
    }
    \vspace{0.15cm}
    \size{32.4}{\@examsubject}\par%
    \vspace{0.4cm}
    \@sectiononeinfo%
    \clearpage%
    \normalfont%
    \pagestyle{sectionone}%
    \do@examsection% section break
}

% title for Section 2
\newcommand\sectiontwotitle{%
    \do@examsection% section break
    % geometry for section two title
    \newgeometry{
        asymmetric, % marginpar is always on the right
        nohead,
        nomarginpar,
        vmargin={2.4cm, 2.35cm}, hmargin={2.5cm, 2.5cm},
        footskip=0.45cm
        % marginparwidth=0cm,
        % marginparsep=0cm
    }
    \pagestyle{sectiontwo}%
    \sffamily%
    \raggedright%
    \fbox{\textbf{\@examyear}} \size{7.5}{\textbf{\uppercase{\@examtitle}}} \par%
    \vspace{1.2cm}
    \size{18}{\textbf{\@examsubject}\par \textbf{Section II Answer Booklet}\par}%
    \vspace{3.8cm}
    \@sectiontwoinfo
    \hrulefill
    \vfill
    \begin{center}
        \textbf{Please turn over}
    \end{center}
    \vfill
    \clearpage%
    % geometry for section two
    \newgeometry{
        asymmetric, % marginpar is always on the right
        nohead,
        vmargin={2.3cm, 2.3cm}, hmargin={2.5cm, 4cm},
        footskip=0.4cm,
        marginparwidth=1cm,
        marginparsep=0.5cm
    }
    \normalfont%
    \pagestyle{sectiontwobody}
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ANSWER BOX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make answer box
% \answerbox[3] makes a box with three horizontal lines
\newcounter{i@line}% iterator for the number of lines
\newcommand\answerbox[1][4]{%
    \setlength{\parskip}{0.35cm}
    \setcounter{i@line}{0}%
    \@whilenum\value{i@line}<#1\do{%
        \par\dottedline%
        \stepcounter{i@line}%
    }%
    \vspace{0.15cm minus 0.15cm}
    \par%
}

% dotted line for answer box
\newcommand{\dottedline}{%
    \leavevmode\cleaders\hbox to 0.25em{\hss .\hss }\hfill\kern0pt%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MISCELLANEOUS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% informative statements
\newcommand\statement[1]{%
    \fullwidth{\begin{center}\textbf{#1}\end{center}}%
}

% insert a page break within a question
\newcommand\questionbreak{%
    \statement{Question {\thequestion} continues on page {\the\numexpr\thepage+1\relax}}
    \clearpage
    Question {\thequestion} (continued)\par
}

% end of question
\newcommand\questionend{%
    \statement{End of Question {\thequestion}}
}

% insert image in the middle
% usage: \includecenteredgraphics[option]{fig/image-name}
\newcommand\includecenteredgraphics[2][]{%
    {\centering\includegraphics[#1]{#2}\par}%
}

% insert blank page
\def\blankpage{%
    \clearpage
    % use section one styling
    \restoregeometry
    \pagestyle{sectionone}
    \hspace{0cm}
    \vfill
    \begin{center}
        BLANK PAGE
    \end{center}
    \vfill
}

% extra writing space for section 2
\newcommand\writingspace{%
    \newgeometry{
        asymmetric, % marginpar is always on the right
        nohead,
        nomarginpar,
        vmargin={2.9cm, 2.35cm}, hmargin={1.45cm, 1.45cm},
        footskip=0.45cm
    }
    \thispagestyle{sectiontwo}
    \fbox{%
        \begin{minipage}{\dimexpr\linewidth - 2\fboxsep -2\fboxrule\relax}
            \setlength{\parskip}{0.35cm}
            \vspace{0.15cm}
            \hspace{0.15cm}{\textbf{\large Section II extra writing space}}\par
            \hspace{0.15cm}\textbf{If you use this space, clearly indicate which question you are answering.}\par
            \vspace{0.15cm}
            \setlength{\parskip}{0.5cm}
            \setcounter{i@line}{0}%
            \@whilenum\value{i@line}<21\do{%
                \par\hrulefill%
                \stepcounter{i@line}%
            }%
            \par\hspace{0cm}
        \end{minipage}%
    }%
    \clearpage
}

% run specified command until the total number of pages is a multiple of four
\newcounter{i@page} % iterator for the page number
\newcommand\fillbooklet[1]{%
    \setcounter{i@page}{\thepage}% i@page is the page number where \end{questions} is located
    % if i@page is not a multiple of four
    % see the definition of \do@ifmultipleof in quiz.cls for more information
    \loop\ifnum\numexpr(\value{i@page}/4)*4-\value{i@page}=0\else%
        % add a new page and repeat
        \newpage%
        #1%
        \stepcounter{i@page}%
    \repeat
}
