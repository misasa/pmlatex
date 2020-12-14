# gem package -- pmlatex

Upload PDF file created with `pmlatex.sty` to App by Medusa.

# Description

Upload PDF file created with `pmlatex.sty` to App run by Medusa.
Create bib record in App by Medusa, upload corresponding PDF file to
App, and link them.  Also replace PDF file and update title, date, and
author.

# Dependency

Ruby 2.5, 2.6, or 2.7.

## [gem package -- medusa_rest_client](https://github.com/misasa/medusa_rest_client "follow instruction")


# Installation

Install the package by yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
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
