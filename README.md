# latex-test-templates

This is a set of LaTeX templates for simple quiz and test setups. All templates are based on the [exam package](https://ctan.org/pkg/exam).

## List of Templates
- `quiz.cls`: For a quiz, one or two pages long
- `test.cls`: (upcoming) For a test with a front page and multiple pages long
- `hsc.cls` : (upcoming) For an exam with HSC styling
- `ib.cls` : (upcoming) For an exam with IB styling

## Features
- Most of the adjustments and definitions happen in the background, and main.tex file only contains the content and pre-defined macros.
- You can assign marks for each question and part of a question, and it calculates and displays the total marks.
- You can assign answers to the questions, and it can print the answers on a separate page.
- It roughly follows the IB-style font setup (Arial for text and Times-like for math).
- You can convert the generated PDF file to Word Document without breaking most of the layout.
