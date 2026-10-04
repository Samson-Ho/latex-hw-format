# Latex-HW-Format specification

## 1. Document and title format

Use the HW-1-style base:

```tex
\documentclass[a4paper, 11pt]{article}

\usepackage[margin=1in]{geometry}
\usepackage{amsmath, amssymb, amsthm}
\usepackage{siunitx}
\usepackage{physics}
\usepackage{fontspec}
\usepackage{enumitem}
\usepackage{xcolor}
\usepackage{graphicx}
\usepackage[hidelinks]{hyperref}
\usepackage{orcidlink}
\usepackage{lastpage}
\usepackage{fancyhdr}

\pagestyle{fancy}
\fancyhf{}
\fancyfoot[C]{\thepage\ /\ \pageref{LastPage}}
\renewcommand{\headrulewidth}{0pt}
```

Set the title in two lines:

```tex
\title{\textbf{<Course> - <Term>}\\ \Large <HW number>}
```

Default author layout:

```tex
\author{
    Sun-Hsing Ho\textsuperscript{\orcidlink{0009-0002-1134-299X}} \\
    \href{mailto:b13209041@g.ntu.edu.tw}{\texttt{b13209041@g.ntu.edu.tw}}
}
```

Use the assignment date supplied by the user. Do not copy grammatical ordinal mistakes from old files; plain forms such as `21 September 2026` are acceptable unless the user specifies another date style.

Immediately after `\begin{document}` use:

```tex
\maketitle
\thispagestyle{fancy}
```

The `\thispagestyle{fancy}` line is required so the first page uses the same footer.

## 2. Problem/chapter structure

Mirror the HW-3 organization. For every problem, begin with the visual source separator:

```tex
%----------------------------------------------------------------------------------------
% PROBLEM <n>
%----------------------------------------------------------------------------------------
```

If the textbook identifier is known, place it directly in the problem heading:

```tex
\section*{Problem <n>: CH <chapter.exercise>}
```

Examples when the assignment crosses chapters:

```tex
\section*{Problem 1: CH 2.7}
\section*{Problem 2: CH 3.1}
\section*{Problem 3: CH 5.12}
```

Do not add a separate `Chapter 2`, `Chapter 3`, etc. heading unless requested. The chapter reference belongs to each problem heading.

If the source gives no chapter/exercise number:

```tex
\section*{Problem <n>}
```

Never infer or fabricate chapter numbers.

## 3. Question and solution blocks

Place the question immediately below the problem heading:

```tex
\textbf{Question:} <question text>

\vspace{0.5em}
\noindent\textbf{Solution:}
```

Preserve the question text faithfully unless editing/rephrasing is explicitly requested.

For a worked solution, use the HW-3 step format:

```tex
\begin{enumerate}[label=\textbf{Step \arabic*:}, leftmargin=*]
    \item \textbf{First step title:} \\
    <derivation or explanation>

    \item \textbf{Second step title:} \\
    <derivation or explanation>
\end{enumerate}
```

Use short, descriptive bold step titles. Preserve existing equations, `itemize`, tables, and figures within a step.

## 4. Problem separators

After a completed problem use:

```tex
\hrulefill
```

Then leave a blank line before the next problem comment block. Match HW-3 by also allowing the final problem to end with `\hrulefill` before `\end{document}`.

## 5. Formatting priorities when editing an existing file

Apply changes in this priority order:

1. Preserve mathematical content and the user's actual answer.
2. Normalize the title and page footer to HW-1 style.
3. Normalize exercise organization to HW-3 style.
4. Preserve extra packages needed by the document.
5. Remove or change packages only when they cause a real conflict or the user asks for cleanup.

Do not introduce a table of contents, numbered sections, chapter grouping, headers, decorative boxes, or a different page-number style unless requested.
