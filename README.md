# Pmlatex

Upload PDF file created by `pmlatex.sty` and `pdflatex` to Medusa

# Dependency

### [medusa_rest_client](http://devel.misasa.okayama-u.ac.jp/gitlab/gems/medusa_rest_client/tree/master "follow instruction")


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

# Contributing

1. Fork it ( https://github.com/[my-github-username]/pmlatex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request