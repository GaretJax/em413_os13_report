\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{mitdoc}[2025/09/10 MIT Documents by Jonathan Stoppani]

\newif\if@showtodos
\@showtodosfalse
\DeclareOption{showtodos}{
  \@showtodostrue
}

\ProcessOptions\relax

\LoadClass[10pt,oneside]{book}
\RequirePackage{etoolbox}
\usepackage[dvipsnames,table]{xcolor}

% Layout definition
\RequirePackage{geometry}
\geometry{a4paper,headsep=4mm,tmargin=1.8cm,bmargin=1.8cm,lmargin=1.4cm,rmargin=1.4cm}
\RequirePackage{multicol}
\RequirePackage{afterpage}
\RequirePackage{pdflscape}

\RequirePackage{soul}

% Paragraphs
\newlength\listindent
\setlength{\listindent}{2em}
\setlength{\headheight}{12.4pt}
\setlength\abovedisplayskip{0pt}%
\setlength\belowdisplayskip{0pt}%
\setlength{\abovecaptionskip}{5pt}
\setlength{\belowcaptionskip}{0pt}
\setlength\baselineskip{11pt}

% Font and encoding
\RequirePackage[T1]{fontenc}
\RequirePackage{anyfontsize}
\RequirePackage{fvextra}
\RequirePackage{csquotes}
% Set font for source code listings
\RequirePackage{fontspec}
\RequirePackage{mathtools}
\RequirePackage[warnings-off={mathtools-colon,mathtools-overbracket}]{unicode-math}
% Set font for headings (texgyrheros)
\newfontfamily{\headingsfont}{texgyreheros}[
  WordSpace = {1,1.4,1},
  Extension = .otf,
  UprightFont = *-regular,
  ItalicFont = *-italic,
  BoldFont = *-bold,
  BoldItalicFont = *-bolditalic,
  Numbers = Lining,
  Scale=1,
]
\newfontfamily{\captionslabel}{texgyreheros}[
  WordSpace = {1,1.4,1},
  LetterSpace = 0,
  Extension = .otf,
  UprightFont = *-regular,
  ItalicFont = *-italic,
  BoldFont = *-bold,
  BoldItalicFont = *-bolditalic,
  Numbers = Lining,
  Scale=1,
]
\setsansfont{texgyreheros}[
  WordSpace = {1,1.4,1},
  Extension = .otf,
  UprightFont = *-regular,
  ItalicFont = *-italic,
  BoldFont = *-bold,
  BoldItalicFont = *-bolditalic,
  Numbers = Lining,
  Scale=1,
]
\setmainfont{texgyreheros}[
  Extension = .otf,
  UprightFont = *-regular,
  ItalicFont = *-italic,
  BoldFont = *-bold,
  BoldItalicFont = *-bolditalic,
  Numbers = Lining,
  Scale=1,
]
\setmathfont{STIXTwoMath-Regular}[
  Scale=MatchUppercase,
  Extension = .otf,
  RawFeature = {+ss01, -ss02, -ss08},
]
\RequirePackage[varl,varqu,hyphenate,mono]{zi4}% sans typewriter font; mono = fixed word spacing, hyphenate = allow hyphenation
\setmonofont{inconsolata}
% ss01 -- switch calligraphic to script; +ss02 -- variants of g, u, v, w, z; +ss08 -- upright integrals
\newcommand*{\FRAC}[1]{{\addfontfeature{Fractions=On}#1}}% use OpenType feature for fractions, \FRAC{1/2}

% Line spacing
\RequirePackage{setspace}
\setstretch{1.1}

% Headings
\RequirePackage[explicit]{titlesec}

% Chapter titles

% Avoid page break before new chapter
\makeatletter
\patchcmd{\chapter}{\if@openright\cleardoublepage\else\clearpage\fi}{}{}{}
\makeatother

\makeatletter
\newcommand\resetnobreak{\@nobreakfalse}
\makeatother

\titleformat{\chapter}
  {\headingsfont\Large\bfseries}
  {}
  {0mm}
  {%
    \tikz{\fill[fill=palette3] (0,0) rectangle (\linewidth,2mm);}
    \textcolor{palette2}{\IfInteger{\thechapter}{\num[minimum-integer-digits=2]{\thechapter}}{\thechapter}.}
    \raggedright#1
  }
\titleformat{name=\chapter,numberless}
  {\headingsfont\Large\bfseries}
  {}
  {0mm}
  {\raggedright#1}
\titlespacing*{\chapter}{0mm}{-13.5mm}{4mm}

\titleformat{\section}
  {\headingsfont\fontsize{11pt}{11pt}\selectfont\bfseries}
  {}
  {0mm}
  {\thesection\enspace#1}
\titleformat{name=\section,numberless}
  {\headingsfont\fontsize{10pt}{11pt}\selectfont\bfseries}
  {}
  {0mm}
  {#1}
\titlespacing*{\section}{0mm}{1pt + \baselineskip}{1mm}

\titlespacing*{\subsection}{0mm}{\baselineskip}{1mm}
\titleformat{\subsection}
  {\headingsfont\fontsize{10pt}{11pt}\selectfont\bfseries}
  {\thesubsection}
  {1mm}
  {\raggedright#1}

\titlespacing*{\subsubsection}{0mm}{0.5\baselineskip}{0mm}
\titleformat{\subsubsection}[runin]
  {\headingsfont\fontsize{10pt}{11pt}\selectfont\bfseries}
  {\thesubsection}
  {1mm}
  {\raggedright#1.\;\;}

\newcommand{\usection}[1]{
  \phantomsection
  \section*{#1}
  \addcontentsline{toc}{section}{\numberline{}#1}
}
\newcommand{\usubsection}[1]{
    \subsection*{#1}
    \addcontentsline{toc}{subsection}{\numberline{}#1}
}
\newcommand{\lchapter}[2][\_nolabel]{%
    \clearpage
    \chapter{#2}%
    \thispagestyle{chapterstart}%
    \ifthenelse{\equal{#1}{\_nolabel}}{}{\label{sec:#1}}%
}
\newcommand{\uchapter}[2][\_nolabel]{%
    \clearpage
    \chapter*{#2}%
    \thispagestyle{chapterstart}%
    \addcontentsline{toc}{chapter}{\numberline{}#2}
    \ifthenelse{\equal{#1}{\_nolabel}}{}{\label{sec:#1}}%
}
\newcommand{\lsection}[2][\_nolabel]{%
    \section{#2}%
    \ifthenelse{\equal{#1}{\_nolabel}}{}{\label{sec:#1}}%
}
\newcommand{\lsubsection}[2][\_nolabel]{
    \subsection{#2}
    \ifthenelse{\equal{#1}{\_nolabel}}{}{\label{sec:#1}}
}
\newcommand{\lsubsubsection}[2][\_nolabel]{
    \subsubsection{#2}
    \ifthenelse{\equal{#1}{\_nolabel}}{}{\label{sec:#1}}
}

\let\origchapter\chapter
\def\chapter{\addtocontents{lol}{\protect\addvspace{10pt}}\origchapter}

\makeatletter
\patchcmd{\@makechapterhead}{50\p@}{0pt}{}{}
\patchcmd{\@makeschapterhead}{50\p@}{0pt}{}{}
\makeatother

\newcommand{\settitle}[2]{%
  \title{#1 -- #2}
  \def\doctitle{#1}
  \def\subtitle{#2}
}

% Enable the use of footnotes in section headings
% http://www.tex.ac.uk/cgi-bin/texfaq2html?label=ftnsect
\RequirePackage[stable]{footmisc}
\let\oldfootnote\footnote
\renewcommand\footnote[1]{\oldfootnote{\hspace{1ex}#1}}

% Customize headers and footers
\RequirePackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\renewcommand{\footruleskip}{7pt}
\renewcommand{\headruleskip}{1pt}

\newbool{frontfoot}
\newcommand{\CommonHead}{
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
}
\newcommand{\CommonHeadTwo}{
    \renewcommand{\headrulewidth}{0.4pt}
    \fancyhead[L]{\small{}\doctitle\vspace{1mm}}
    \fancyhead[R]{\small{}\authorslist\vspace{1mm}}
}
\newcommand{\CommonFoot}{
    \renewcommand{\footrulewidth}{0.4pt}
    \fancyfoot[L]{\footnotesize{}\subtitle}
    \fancyfoot[R]{\footnotesize{}\ifbool{frontfoot}{\thepage}{\thepage~/~\pageref{LastPage}}}
}
\fancypagestyle{front}{%
    \CommonHead
    %\renewcommand{\headrulewidth}{0.4pt}
    %\renewcommand{\footrulewidth}{0.4pt}
    %\fancyfoot[L]{\small{}\subtitle}
}
\fancypagestyle{chapterstart}{%
    \CommonHead
    \renewcommand{\headrulewidth}{0pt}
    \CommonFoot
}
\fancypagestyle{main}{%
    \CommonHead
    \CommonHeadTwo
    \CommonFoot
}
\fancypagestyle{plain}{
    \CommonHead
    \CommonHeadTwo
    \CommonFoot
}

% Toc settings
\RequirePackage[subfigure]{tocloft} % load it first to avoid conflicts
\setlength{\cftchapnumwidth}{23pt}
\renewcommand{\cftchappresnum}{}
\renewcommand{\cftchapaftersnum}{\hspace*{6pt}}
\renewcommand{\cftchapfont}{\bf}
%\renewcommand\cftloftitlefont{\hspace{15pt}\bf\Huge}
\setlength{\cftbeforechapskip}{5pt}
\setlength{\cftbeforesecskip}{0pt}
\setlength{\cftbeforefigskip}{0pt}
\setlength{\cftbeforetabskip}{0pt}
\setlength{\cftsecindent}{0pt}
\setlength{\cftsubfignumwidth}{19pt}
\setlength{\cftsubfigindent}{46pt}
\setlength{\cftfigindent}{13pt}
\setlength{\cftsubtabnumwidth}{19pt}
\setlength{\cftsubtabindent}{46pt}
\setlength{\cfttabindent}{13pt}
\newcounter{lofdepth}\setcounter{lofdepth}{2}
\newcounter{lotdepth}\setcounter{lotdepth}{2}

% Limit the \gls{toc} dept to sections and subsections
\setcounter{tocdepth}{1}
\setcounter{secnumdepth}{2}

% Allow advanced list typesetting
\RequirePackage{paralist}% Inline lists
\RequirePackage{enumitem}
\setlist{leftmargin=\listindent}

% Includegraphics support
\RequirePackage{graphicx}
\RequirePackage{wrapfig}
%\RequirePackage{dblfloatfix}
% Use subfloats for figures and tables (must be loaded after the caption and tocloft packages)
\RequirePackage[lofdepth,lotdepth]{subfig}
\RequirePackage{pdfpages}% Advanced inclusion support for external documents
\newenvironment{inlinefigure}[1]
  {\vspace{-1.1mm}\par\noindent\minipage[b][#1\baselineskip][c]{\linewidth}\setlength{\parindent}{0em}\vspace{2.6mm}}
  {\endminipage\par}

% Tables
\RequirePackage{multirow}% Enable columns spawning multiple rows
\RequirePackage{tabularx}
\RequirePackage{makecell}
\RequirePackage{rotating}
\RequirePackage{booktabs}% Provides {top|middle|bottom}rule
\RequirePackage{longtable} % Support for tables spawning multiple pages,
                       % captions and footnotes.
                       % Does not work in multicolumn environments
% Define new tabularx column types:
%  - R: streteched right aligned
%  - C: stretched centered
\newcolumntype{L}{>{\raggedright\arraybackslash}X}%
\newcolumntype{E}[1]{>{\setstretch{1}\raggedright\arraybackslash}p{#1}}%
\newcolumntype{R}{>{\raggedleft\arraybackslash}X}%
\newcolumntype{I}[1]{>{\raggedleft\arraybackslash}p{#1}}%
\newcolumntype{C}{>{\centering\arraybackslash}X}%
\newcolumntype{N}[1]{>{\centering\arraybackslash}p{#1}}%
\renewcommand{\arraystretch}{1.1} % Set row height multiplicator
\aboverulesep = 0.4ex
\belowrulesep = 0.5ex
\RequirePackage{threeparttable} % Manual footnotes counter
%\AtBeginEnvironment{tabularx}{\footnotesize}

\AtBeginEnvironment{longtable}{\footnotesize}
\newcommand{\Th}[1]{\textsf{\textbf{\footnotesize #1}}}

% Assign the LastPage label to the last page
\RequirePackage{lastpage}

% Enable the creation of appendices
\RequirePackage{appendix}

% Typesetting units
\RequirePackage{siunitx}
\sisetup{
  group-digits = true,
  range-phrase=--,
  range-units=single,
  detect-all=true,
  group-separator={,},
}
% Versions with square brackets, even if they should not be used
\newcommand{\pct}[1]{\num{#1}\,\si{\%}}
\newcommand{\Qty}[3][]{\mbox{$\num[#1]{#2}\,\left[\si{#3}\right]$}}
\newcommand{\Unit}[1]{\mbox{$\left[\si{#1}\right]$}}
\newcommand{\USD}[2][0]{%
  \SI[round-precision=#1,round-mode=places,round-integer-to-decimal]{#2}[USD\,]{}}
\newcommand{\USDk}[1]{\SI{#1}[USD\,]{k}}
\newcommand{\USDM}[1]{\SI{#1}[USD\,]{M}}

% Typography shortcuts
\newcommand\ie{i.e.,\ }
\newcommand\eg{e.g.,\ }

% Typography support
\usepackage[super]{nth}% Support for 2nd, 3rd,...
\usepackage[normalem]{ulem}% Text strikeout

% Typeset paragraph titles
\RequirePackage[noadjust]{marginnote}
\newcommand{\p}[1]{%
    \leavevmode\marginnote{\vspace{-.8mm}\sffamily\scriptsize\setstretch{1.4}#1}%
    \ignorespaces
}

% Add \say for inline citations
\RequirePackage{dirtytalk}

% Advanced math support
\let\bigtimes\relax% conflicts with times
\let\widebar\relax% conflicts with times
\RequirePackage{amsmath}
\usepackage[makeroom]{cancel}
\RequirePackage{xfrac}
\RequirePackage[italicdiff]{physics}  % differential notations
\newcommand{\pp}{\quantity}
\AtBeginDocument{\RenewCommandCopy\qty\SI}

% Language
\RequirePackage[american]{babel}

\RequirePackage{zref-abspage}
\RequirePackage{zref-abspos}

% Bibliography
% Advanced citation tools
% \RequirePackage[numbers,sort&compress]{natbib}
%\RequirePackage[notes, short, backend=biber]{biblatex-chicago}
\RequirePackage[autocite=superscript, sorting=none, style=numeric, backend=biber]{biblatex}
\addbibresource{bibliography.bib}
\setlength{\bibhang}{0.2\parindent}
\setlength{\bibitemsep}{0\baselineskip}
\AtBeginBibliography{\footnotesize}
\DeclareFieldFormat{labelnumberwidth}{#1.}
\DeclareFieldFormat{labelnumberwidth}{#1\adddot}% forgot this; from Audrey's comment 

\defbibenvironment{bibliography}
  {\list
     {\printtext[labelnumberwidth]{%
        \printfield{prefixnumber}%
        \printfield{labelnumber}}}
     {\setlength{\labelwidth}{\labelnumberwidth}%
      \setlength{\leftmargin}{\labelwidth}%
      \setlength{\labelsep}{0mm}%
      \addtolength{\leftmargin}{\labelsep}%
      \setlength{\itemsep}{\bibitemsep}%
      \setlength{\parsep}{\bibparsep}}%
      \renewcommand*{\makelabel}[1]{##1}}
  {\endlist}
  {\item}

% Authors listings
\RequirePackage{fp}
\newcounter{authorsindex}
\newcounter{authorscount}
\newcommand{\addauthor}[1]{%
    \listadd{\authors}{#1}
    \stepcounter{authorscount}
}
\newcommand{\fmtauthor}[1]{#1}
\renewcommand{\fmtauthor}[1]{#1}
\newcommand{\lineslist}[1]{#1\\}
\newcommand{\authorlines}{%
    \setcounter{authorsindex}{0}%
    \FPdiv{\limit}{\arabic{authorscount}}{2}%
    \FPround{\limit}{\limit}{0}%
    \renewcommand*{\do}[1]{%
        \ifnumequal{\value{authorsindex}}{0}{}{\\[0.7mm]}%
        \fmtauthor{##1}%
        \stepcounter{authorsindex}%
    }%
    \dolistloop{\authors}%
}
\newcommand{\authorslist}{%
    \setcounter{authorsindex}{0}%
    \renewcommand*{\do}[1]{%
        \ifnumequal{\value{authorsindex}}{0}{}{, }%
        \fmtauthor{##1}%
        \stepcounter{authorsindex}%
    }%
    \dolistloop{\authors}%
}

% Source code listing
\RequirePackage[chapter]{minted}
\definecolor{verylightgray}{RGB}{240,240,240}
\newfontfamily\monaco{inconsolata}[NFSSFamily=InconsolataFamily]
\setminted[python]{fontfamily=InconsolataFamily}
\BeforeBeginEnvironment{minted}{\vspace{2cm}}
\renewcommand{\theFancyVerbLine}{\ttfamily \textcolor[rgb]{0.5,0.5,0.5}{\scriptsize \oldstylenums{\arabic{FancyVerbLine}}}\hspace{-5pt}}
\newenvironment{code}[2]{%
  \captionsetup{type=listing,justification=raggedright,singlelinecheck=false}%
  \caption{#2}\label{#1}%
  \vspace{-8pt}%
}{}
\setminted{
  bgcolor=verylightgray,
  fontfamily=courier,
  frame=single,
  rulecolor=verylightgray,
  framesep=5pt,
  breaklines=true,
  linenos=true,
  fontfamily=InconsolataFamily,
  fontsize=\small,
  baselinestretch=1,
}

% Caption settings
\RequirePackage[labelfont=bf,font={sf,small},labelsep=space]{caption}
\DeclareCaptionLabelFormat{halfquad}{\MakeUppercase{#1} #2$\mkern8mu$}
\captionsetup{labelformat=halfquad}
\captionsetup[listing]{name=Listing}
\newcommand{\landscapecaption}[2]{\captionsetup{labelsep=none,singlelinecheck=false}\caption{#2}\label{#1}}
\newcommand{\landscapecaptioncontd}[2]{\captionsetup{labelsep=none,singlelinecheck=false}\caption*{\textbf{\ref{#1}} (cont'd)$\mkern8mu$#2}}

% Advanced automatic reference
\RequirePackage{varioref}
\labelformat{chapter}{chapter~#1}
\labelformat{section}{section~#1}
\labelformat{subsection}{subsection~#1}
\labelformat{subsubsection}{subsubsection~#1}
\labelformat{algorithm}{Algorithm~#1}
\labelformat{figure}{Figure~#1}
\labelformat{subfigure}{Subfigure~\thefigure#1}
\labelformat{table}{Table~#1}
\labelformat{equation}{Equation~#1}
\labelformat{listing}{Listing~#1}
\labelformat{plot}{Plot~#1}
\newcounter{interviewcntr}[chapter]
\newcounter{questioncntr}[section]
\newcounter{needcntr}[table]
\addto\extrasenglish{
  %\renewcommand{\figurename}{Chart}
  \renewcommand\reftextfaceafter{on the next page}%
  \renewcommand\reftextafter{on the next page}%
  \renewcommand\reftextfacebefore{on the previous page}%
  \renewcommand\reftextbefore{on the previous page}%
}

% Drawing and plotting
\RequirePackage{tikz}
\RequirePackage{tikzscale}
\RequirePackage{tikzpagenodes}
\usetikzlibrary{arrows.meta}
\usetikzlibrary{calc}
\usetikzlibrary{tikzmark}
\usetikzlibrary{decorations.pathreplacing}
\usetikzlibrary{decorations.text}
\usetikzlibrary{fadings}
\usetikzlibrary{intersections}
\usetikzlibrary{math}
\usetikzlibrary{matrix}
\usetikzlibrary{perspective}
\usetikzlibrary{positioning}
\usetikzlibrary{shapes.arrows}
\usetikzlibrary{shapes.multipart}
\usetikzlibrary{shapes.geometric}
\usetikzlibrary{through}
\usetikzlibrary{fit}
\usetikzlibrary{backgrounds}

\usepackage{pgfplots}
\usepackage{pgfplotstable}
\usepgfplotslibrary{dateplot}
\usepgfplotslibrary{fillbetween}
\usepgfplotslibrary{groupplots}
\pgfplotsset{compat=newest}
\pgfplotsset{%
    myplot/.style={%
      set layers,
      width=\linewidth,
      height=0.3\textheight,
      xtick pos=left,
      xtick distance=30,
      ytick pos=left,
      yticklabel={$\pgfmathprintnumber{\tick}$},
      ylabel style={font=\footnotesize},
      legend cell align={left},
      legend style={%
        nodes={font=\footnotesize, yshift=-1pt},
        legend pos=north west,
        xshift=5pt,
        yshift=-7pt,
        inner ysep=3pt,
      },
      reverse legend,
      scaled y ticks=false,
      scale only axis,
      enlargelimits=0.03,
      enlarge x limits=0.03,
      enlarge y limits=0.03,
      xmajorgrids=true,
      ymajorgrids=true,
      grid style={line width=.1pt, draw=gray!50},
    },
    monthly/.style={
      date coordinates in=x,
      xticklabel = {\year-\month},
      xticklabel style={
        xshift=-6pt,
        yshift=1pt,
        rotate=50,
        font=\footnotesize,
      },
    },
    quarterly/.style={
      date coordinates in=x,
      monthly,
    },
    yearly/.style={
      date coordinates in=x,
      xticklabel = {\year},
      xticklabel style={
        xshift=0pt,
        yshift=-2pt,
        font=\footnotesize,
      },
      enlarge x limits={0.125},
    },
    stacked areas/.style={
      area style,
      stack plots=y,
      axis on top=false,
    },
    stacked ybars/.style={
      ybar stacked,
      stack negative=separate,
      axis on top=false,
    },
    small-dates/.style={
      xticklabel style={
        font=\scriptsize,
      },
    },
    MSEK/.style={
      ylabel=MSEK,
      scaled y ticks=base 10:-6,
      ytick scale label code/.code={},
    },
    kSEK/.style={
      ylabel=kSEK,
      scaled y ticks=base 10:-3,
      ytick scale label code/.code={},
    },
    kUSD/.style={
      ylabel=kUSD,
      scaled y ticks=base 10:-3,
      ytick scale label code/.code={},
    },
    legend above/.style={
      legend columns=-1,
      legend style={%
        nodes={font=\footnotesize, yshift=2pt},
        /tikz/every even column/.append style={column sep=2mm},
        at={(0.5,1.08)},
        anchor=south,
      },
    },
    short/.style={
      height=0.23\textheight,
    },
    very short/.style={
      height=0.2\textheight,
    },
    pct/.style={
      ymin=0,
      scaled y ticks=base 10:2,
      ytick scale label code/.code={},
      yticklabel={$\pgfmathprintnumber{\tick}\%$},
    },
    /pgf/number format/.cd,1000 sep={\text{'}},
    /pgf/number format/fixed,
    /pgf/number format/precision=5,
}
\newcommand\zeroline{%
  \draw[black] (2000-01-01,0)--(2050-01-01,0);
}
\newcommand{\barleg}[1]{
    \fill[#1] (0pt,-1.4pt) rectangle++(3pt,7.5pt);
    \fill[#1] (5.5pt,-1.4pt) rectangle++(3pt,4.5pt);
}
\newcommand\alignOnFrame{%
  \coordinate (A) at ($(current bounding box.south west -| current axis.south west)$);
  \coordinate (B) at ($(current bounding box.north east -| current axis.south east)$);
  \pgfresetboundingbox
  \path (A) rectangle (B);
}
\newcommand\reduceFrameBottom[1]{%
  \coordinate (A) at ($(current bounding box.south west)$);
  \coordinate (B) at ($(current bounding box.north east)$);
  \pgfresetboundingbox
  \path ([shift={(0,#1)}] A) rectangle (B);
}


\makeatletter
\pgfdeclareshape{document}{
  \inheritsavedanchors[from=rectangle] % this is nearly a rectangle
  \inheritanchorborder[from=rectangle]
  \inheritanchor[from=rectangle]{center}
  \inheritanchor[from=rectangle]{north}
  \inheritanchor[from=rectangle]{south}
  \inheritanchor[from=rectangle]{west}
  \inheritanchor[from=rectangle]{east}
  \inheritanchor[from=rectangle]{south east}
  \inheritanchor[from=rectangle]{south west}
  % ... and possibly more
  \backgroundpath{% this is new
    % store lower right in xa/ya and upper right in xb/yb
    \southwest \pgf@xa=\pgf@x \pgf@ya=\pgf@y
    \northeast \pgf@xb=\pgf@x \pgf@yb=\pgf@y
    % compute corner of ‘‘flipped page’’
    \pgf@xc=\pgf@xb \advance\pgf@xc by-8pt % this should be a parameter
    \pgf@yc=\pgf@yb \advance\pgf@yc by-5pt
    % construct main path
    \pgfpathmoveto{\pgfpoint{\pgf@xa}{\pgf@ya}}
    \pgfpathlineto{\pgfpoint{\pgf@xa}{\pgf@yb}}
    \pgfpathlineto{\pgfpoint{\pgf@xc}{\pgf@yb}}
    \pgfpathlineto{\pgfpoint{\pgf@xb}{\pgf@yc}}
    \pgfpathlineto{\pgfpoint{\pgf@xb}{\pgf@ya}}
    \pgfpathclose
    % add little corner
    \pgfpathmoveto{\pgfpoint{\pgf@xc}{\pgf@yb}}
    \pgfpathlineto{\pgfpoint{\pgf@xc}{\pgf@yc}}
    \pgfpathlineto{\pgfpoint{\pgf@xb}{\pgf@yc}}
    \pgfpathlineto{\pgfpoint{\pgf@xc}{\pgf@yc}}
  }
}
\makeatother

% Custom packages
\RequirePackage{autocontent}

% Support for internal links
% Hyperref must (almost) always be printed at the end
\RequirePackage{url}
\RequirePackage{xurl}
\RequirePackage[bookmarks=true]{hyperref}
\hypersetup{
    colorlinks=true,
    linkcolor=black,
    filecolor=black,
    urlcolor=black,
    citecolor=blue,
}
\RequirePackage{bookmark}

% Enable the creation of glossaries
\RequirePackage[nomain,section,acronym,nonumberlist]{glossaries}
\RequirePackage{glossary-inline}
\newglossary*{req}{Requirement terms}
\glsdisablehyper
\renewcommand*{\glsautoprefix}{glo:}
\renewcommand*{\glspostdescription}{ }
%\renewcommand*{\glstextformat}[1]{\textcolor{blue}{#1}}

\newcommand{\markquestionstart}[1]{%
  \tikzmark{qstart}%
  \tikz[remember picture, overlay]{
    \coordinate (start) at (pic cs:qstart);
    \coordinate (side) at ($(0mm,0.3em) + (current page.north west |- 0,0)$);
    \node[
      color=palette3!40!white,fill=palette3,
      font=\scriptsize,
      single arrow,
      single arrow head extend=0mm,
      anchor=west,
      inner xsep=2.5pt,
    ] at (side) {Q\quad\quad\,};
    \node[
      color=white,
      font=\scriptsize,
      single arrow,
      single arrow head extend=0mm,
      anchor=west,
      inner xsep=1pt,
      xshift=3mm,
    ] at (side) {#1};
      %thin, draw, single arrow,
      %inner xsep=0,
      %minimum height=12mm, minimum width=5.8mm,
      %single arrow head extend=0.06mm,
  }%
}

\RequirePackage{atbegshi}

\makeatletter
  \if@showtodos
    \setlength{\marginparwidth}{2cm}
    \paperwidth=\dimexpr \paperwidth + 6cm\relax
    \marginparwidth=5.4cm
    \marginparsep=1.7cm
    \RequirePackage[textwidth=\marginparwidth]{todonotes}
    \AtBeginShipout{
      \AtBeginShipoutUpperLeft{
        \begin{tikzpicture}[remember picture,overlay,scale=-1,shift=(current page.north east)]
          \fill[fill=black!2] (0,0) rectangle (\marginparwidth + 0.6cm,\paperheight);
          \draw[draw=black!20] (\marginparwidth + 0.6cm,0) -- ++(0,\paperheight);
        \end{tikzpicture}
      }
    }
  \else
    \RequirePackage[disable]{todonotes}
  \fi
\makeatother



\newcommand{\markquestionend}{
  \tikzmark{qend}
}

\input{glossary.gls}
\input{stakeholders.tex}
