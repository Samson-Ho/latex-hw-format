---
name: latex-hw-format
description: "Create or reformat LaTeX homework assignments in Samson's preferred house style: an HW-1-style title block and current/total page footer, combined with HW-3-style per-problem chapter labels, Question/Solution blocks, numbered solution steps, and horizontal problem separators. Use when generating, cleaning, or restructuring .tex homework files, especially when the user asks for Latex-HW-Format or provides homework questions/solutions to typeset."
---

# Latex-HW-Format

Format LaTeX homework consistently using the bundled template and reference specification. Treat this skill as a formatting convention: preserve the user's mathematical reasoning and wording unless the user also asks for solving, checking, or rewriting.

## Workflow

1. Read the supplied homework text or `.tex` file and identify the course, term, homework number, date, author metadata, problem order, and textbook chapter/exercise identifiers.
2. For a new document, start from `assets/homework-template.tex`. For an existing document, preserve content and required packages while adapting the title/footer and problem structure to this skill.
3. Apply the title-page and pagination rules in `references/format-spec.md` exactly. Keep the first-page footer active with `\thispagestyle{fancy}` after `\maketitle`.
4. Format each exercise as `Problem n: CH x.y` when a chapter/exercise identifier is known. Allow different problems to reference different chapters; do not create separate chapter grouping sections unless the user asks for them.
5. Preserve each question statement under `\textbf{Question:}`. Put the answer under `\noindent\textbf{Solution:}` and structure multi-step derivations with the `Step 1:`, `Step 2:`, ... enumerate style from the reference.
6. Separate consecutive problems with `\hrulefill` and retain the visual problem comment blocks used by the template.
7. Keep mathematical notation, equations, tables, figures, and citations intact unless a change is required for compilation or explicitly requested.
8. When compilation is available, compile with XeLaTeX or LuaLaTeX because the canonical preamble uses `fontspec`. Fix only formatting/compiler issues necessary for a clean build; do not silently alter mathematical conclusions.

## Required conventions

- Use A4 paper, 11 pt, and 1-inch margins unless the user explicitly overrides them.
- Use the centered footer `\thepage\ /\ \pageref{LastPage}` on every page, including the title page.
- Use the HW-1 author layout by default: name with ORCID on one line and email on the next line. Replace these fields when the user supplies different author metadata.
- Use unnumbered problem sections. Do not let LaTeX auto-number the exercises.
- If no chapter/exercise identifier exists, use `\section*{Problem n}` rather than inventing one.
- Keep question numbering in the order supplied by the user unless renumbering is explicitly requested.

Read `references/format-spec.md` whenever exact source-level formatting is needed. Copy or adapt `assets/homework-template.tex` for new homework files.
