module Pmlatex
  class App
  	def self.global_opts
  		@@global_opts ||= {:verbose => false}
  	end
  	def self.global_opts=(opts)
  		@@global_opts = opts
  	end

    def global_opts
      self.class.global_opts
    end

    def global_opts=(opts)
      self.class.global_opts
    end

  	def self.init(output = STDOUT, argv = ARGV)
      @output = output
      MedusaRestClient::Base.init
#      MedusaApi::Base.init(:pref => "~/.medusarc")
#      @global_opts = global_opts
#      @argv = argv
      self.global_opts = self.global_options(argv)
      sub_command = argv.shift # get the subcommand
      case sub_command
        when "add"
          cui = Pmlatex::Add.new(output, argv)
        when "commit"
          cui = Pmlatex::Commit.new(output, argv)
        when "update"
          cui = Pmlatex::Update.new(output, argv)
        when "scan"
          cui = Pmlatex::Scan.new(output, argv)
       else
          Trollop::die "not implemented"  
        end
      return cui
    end

    
    def self.global_options argv=ARGV
      sub_commands = %w(add commit update scan)

      name = <<-EOS
pmlatex -- upload PDF file created by `pmlatex.sty' and `pdflatex' to
Medusa.
EOS
      name = name.split("\n").map{|line| " "*4 + line}.join("\n")

      history = <<-EOS
June 26, 2015: gem version 0.0.1 released
April 5, 2015: First release with documentation.
EOS
      history = history.split("\n").map{|line| " "*4 + line}.join("\n")

      synopsis = <<-EOS
Create bib record in Medusa, then upload corresponding PDF file to the
record.  Also replace PDF and update title, date, and author.
EOS
      synopsis = synopsis.split("\n").map{|line| " "*4 + line}.join("\n")

      description = <<-EOS
The standard format of DREAM documentation as of April 5 (2015) is PDF
create by combination of `pmlatex.sty' and `pdflatex'.  This program
helps to upload and re-upload the PDF file.  This program has four
sub-command, that are add, commit, update, and scan.

Whenever you finish writing document the first time, you need four
steps; (1) create a bib record in Medusa with appropriate title, date,
and author, (2) embed Medusa-ID into the LaTeX document and recompile
it, (3) upload the PDF file to the bib record, and (4) correlate the
bib record with stones shown up on the document.

On revision the document, you need three steps; (1) remove PDF file
that is correlated with the bib record, (2) update title, date, and
author of the record when necessary, and (3) upload the newest PDF
file.

This program assists those complicated procedures.  Note that this
program reads `~/.orochirc' for Medusa configuration.
EOS
      description = description.split("\n").map{|line| " "*4 + line}.join("\n")

      usage = <<-EOS
 pmlatex add document[.tex]
 pmlatex commit document[.tex]
 pmlatex update document[.tex]
 pmlatex scan document[.tex]
EOS
      usage = usage.split("\n").map{|line| " "*4 + line}.join("\n")

      example = <<-EOS
Let's assume you have finished writing `report.tex'.  You invoke
`pmlatex add report'.  The program scans the document and picks title,
date, and author, and create a new bib on Medusa.  At the same time,
it inserts letters `\BibliographySisyphus{20140806114754-746408}' into
`report.tex'.  You recompile `report.tex'.  You have to correlate the
bib record and stones shown up on the document.  You invoke `pmlatex
scan report'.  The program scans the document, picks stones, and
exports them to `report.ss'.  By handling the `report.ss'
appropriately, you correlate the bib record and the stones.  Then you
invoke `pmlatex commit report' to upload the PDF file to the bib
record.  The commands you invoked on this scene are summarized as
below.

 > pmlatex add report
 > pdflatex report
 > pmlatex scan report
 > pmlatex commit report

Whenever you revise `report.tex' and have the up-to-date `report.pdf',
you want to replace `report.pdf' on Medusa by the newest PDF.  You
invoke `pmlatex commit report' to do so.  You may want to update
title, author, and date on the bib record.  You invoke `pmlatex update
report' to do so.  The commands you invoked on this scene are
summarized as below.

 > pmlatex commit report
 > pmlatex update report
EOS
      example = example.split("\n").map{|line| " "*4 + line}.join("\n")

      see_also = <<-EOS
series of Orochi utilities
icp
http://dream.misasa.okayama-u.ac.jp
EOS
      see_also = see_also.split("\n").map{|line| " "*4 + line}.join("\n")

      implementation = <<-EOS
Orochi, version 9
Copyright (C) 2015 Okayama University
License GPLv3+: GNU GPL version 3 or later
EOS
      implementation = implementation.split("\n").map{|line| " "*4 + line}.join("\n")
      Trollop::options(argv) do
      banner <<-EOS
Usage: pmlatex [options] <subcommand>
  Type 'pmlatex <subcommand> --help' for help on a specific subcommand.

   
  Available subcommands:
  #{sub_commands.join(' ')}

  Name:
#{name}

  History:
#{history}

  Synopsis:
#{synopsis}

  Description:
#{description}

  Usage:
#{usage}

  Example:
#{example}

  See also:
#{see_also}

  Implementation:
#{implementation}

  Global options:
EOS
        opt :verbose, "Run verbosely"
    #  opt :dry_run, "Don't actually do anything", :short => "-n"
        stop_on sub_commands
      end
    end

    def global_opts
      self.class.global_opts
    end

    def verbose
      self.class.global_opts[:verbose]
    end
   
  end


end
