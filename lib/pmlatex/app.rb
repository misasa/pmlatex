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
          Optimist::die "not implemented"  
        end
      return cui
    end

    
    def self.global_options argv=ARGV
      sub_commands = %w(add commit update scan)

      name = <<-EOS
pmlatex -- manage LaTeX documents and PDF attachments in Medusa.
EOS
      name = name.split("\n").map{|line| " "*4 + line}.join("\n")

      history = <<-EOS
August 1, 2017: Documentation updated for gem version 1.0.2.
June 26, 2015: Gem version 0.0.1 released.
April 5, 2015: First release with documentation.
EOS
      history = history.split("\n").map{|line| " "*4 + line}.join("\n")

      synopsis = <<-EOS
Create and update Medusa bibliography records, upload their PDFs,
and link records cited by LaTeX documents.
EOS
      synopsis = synopsis.split("\n").map{|line| " "*4 + line}.join("\n")

      description = <<-EOS
Use documents prepared with pmlatex.sty and an existing TeX toolchain.
This program does not compile LaTeX or generate PDF files.

Available commands:
  add     Create a bibliography record and insert its ID into the source.
  commit  Upload the PDF to the document's bibliography record.
  update  Update the record's title, authors, year, and month.
  scan    Link cited Medusa records to the bibliography record.

All four commands require both the LaTeX source and its compiled PDF.
Pass the document basename, a .tex path, or a .pdf path. For example,
report, report.tex, and report.pdf select report.tex and report.pdf.
Run from the document directory so included files can be found.

For a new document, create the record with add, recompile the source
after its ID is inserted, then run scan and commit. For revisions,
compile the latest PDF and run commit; use update if metadata changed.

The Medusa client reads .orochirc in the current directory first,
then ~/.orochirc. It loads configuration even when displaying help.
EOS
      description = description.split("\n").map{|line| " "*4 + line}.join("\n")

      usage = <<-EOS
pmlatex [--verbose] add DOCUMENT[.tex]
pmlatex [--verbose] commit [--message MESSAGE] DOCUMENT[.tex]
pmlatex [--verbose] update DOCUMENT[.tex]
pmlatex [--verbose] scan DOCUMENT[.tex]
EOS
      usage = usage.split("\n").map{|line| " "*4 + line}.join("\n")

      example = <<-EOS 
Register a new document and upload its PDF:

  pdflatex report          # Create the PDF required by add.
  pmlatex add report       # Back up the source and insert the new ID.
  pdflatex report          # Recompile the source with its new ID.
  pmlatex scan report      # Link records cited by the document.
  pmlatex commit report    # Upload report.pdf.

The add command inserts a line such as \\BibliographySisyphus{ID}
into report.tex and saves the original source as report.tex.backup.
The scan command writes report.ss when any cited records resolve.

Upload a revised PDF and update changed bibliography metadata:

  pdflatex report
  pmlatex commit report
  pmlatex update report

When commit finds an attachment with the same filename, it prompts
to replace it, cancel the upload, or append another attachment.
An empty reply means replace. The update command also prompts before
saving changed metadata; an empty reply means yes.

For command-specific help, run pmlatex COMMAND --help.
EOS
      example = example.split("\n").map{|line| " "*4 + line}.join("\n")

      see_also = <<-EOS
pmlatex add --help
pmlatex commit --help
pmlatex update --help
pmlatex scan --help
https://github.com/misasa/pmlatex
EOS
      see_also = see_also.split("\n").map{|line| " "*4 + line}.join("\n")

      implementation = <<-EOS
pmlatex
Copyright (C) 2015-2020 Okayama University
License: GNU General Public License version 3 or later (GPL-3.0-or-later)
EOS
      implementation = implementation.split("\n").map{|line| " "*4 + line}.join("\n")
      Optimist::options(argv) do
      banner <<-EOS
Usage: pmlatex [options] <subcommand>

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

  Examples:
#{example}

  See also:
#{see_also}

  Implementation:
#{implementation}

  Global options:
EOS
        opt :verbose, "Show additional diagnostic output"
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

    def self.verbose
      self.global_opts[:verbose]
    end
    
  end


end
