# pmlatex

Upload PDF file created by `pmlatex.sty` and `pdflatex` to Medusa

# Description

Upload PDF file created by `pmlatex.sty` and `pdflatex` to Medusa.  Create bib record in Medusa, then upload corresponding PDF file to the record.  Also replace PDF and update title, date, and author.

# Dependency

## [medusa_rest_client](https://github.com/misasa/medusa_rest_client "follow instruction")


# Installation

Add this line to your application's Gemfile:

```ruby
gem 'pmlatex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems
    $ gem install pmlatex

# Commands

Commands are summarized as:

| command          | description                                   | note                       |
|------------------|-----------------------------------------------|----------------------------|
| pmlatex add      | create a bib record in Medusa                 |                            |
| pmlatex commit   | upload pdffile to the bib record              |                            |
| pmlatex update   | update title, date, and author of the record  |                            |
| pmlatex scan     | correlate the bib record with stones          |                            |

# Usage

See online document with option `--help`.
