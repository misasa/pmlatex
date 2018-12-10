# gem package -- pmlatex

Upload PDF file created by `pmlatex.sty` and `pdflatex` to Medusa.

# Description

Upload PDF file created by `pmlatex.sty` and `pdflatex` to Medusa.
Create bib record in Medusa, then upload corresponding PDF file to the
record.  Also replace PDF and update title, date, and author.

# Dependency

## [gem package -- medusa_rest_client](https://github.com/misasa/medusa_rest_client "follow instruction")


# Installation

Install the package by yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems
    $ gem install pmlatex

# Commands

Commands are summarized as:

| command          | description                                    | note                       |
|------------------|------------------------------------------------|----------------------------|
| pmlatex add      | Create a bib record in Medusa.                 |                            |
| pmlatex commit   | Upload pdffile to the bib record.              |                            |
| pmlatex update   | Update title, date, and author of the record.  |                            |
| pmlatex scan     | Correlate the bib record with stones.          |                            |

# Usage

See online document with option `--help`.
