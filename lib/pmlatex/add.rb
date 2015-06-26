module Pmlatex
  class Add < Cui

    def cmd_options(argv=ARGV)
      Trollop::options(argv) do
        banner "  Usage: pmlatex add mylocalfile"
      end
    end

    def start
      raise "invalid args" unless argv.size > 0

      fname = argv.shift
      process_file(fname)
    end

    def process_file(fname)
      #fname = ARGV.shift
      extlist = ['.tex', '.pdf']
      basename = File.basename(fname, ".*")
      dirname = File.dirname(fname)

      texfilename = File.join(dirname, basename + '.tex')
      pdffilename = File.join(dirname, basename + '.pdf')
      raise "Error: A local source-file <#{texfilename}> was not found. This message is generated" unless File.exist?(texfilename);
      raise "Error: An expected PDF-file <#{pdffilename}> was not found. Compile the source file <#{texfilename}> and have the PDF file <#{pdffilename}>. This message is generated" unless File.exist?(pdffilename);
      
      if verbose
#        print "#{year}/#{mon}/#{mday}\n";
      	print "basename: ", basename,"\n";
      	print "tex: ", texfilename,"\n";
      	print "pdf: ", pdffilename,"\n";
      end
      tex = Tex.from_file(texfilename, verbose)

      raise "Error: Document <#{texfilename}> is already paired with record <Bibliography: #{tex.bib_id}>. Delete a line with |BibliographySisyphus| in the document. This message is generated" if tex.bib_id

      tex.title = tex.title || "pmlatex add"
      tex.author = tex.author || "pmlatex";
      tex.date = tex.date || Date.today

      tex.parse_author
      authors = []
      tex.author_fullnames.each do |author_name|
        authors << MedusaRestClient::Author.find_or_create_by_name(author_name)
      end

      bib = MedusaRestClient::Bib.new
      bib.name = tex.title || "pmlatex add"
      bib.entry_type = 'article'
      #bib.authorlist = tex.author || "pmlatex add"
      bib.author_ids = authors.map(&:id)
      bib.journal = 'DREAM Digital Document'
      bib.year = tex.year
      bib.volume = tex.year - 2000
      bib.month = tex.mon
      bib.save
      bib.reload
      bib.pages = bib.global_id
      bib.save
      bib.reload

      copy_from = texfilename
    	copy_to   = texfilename + ".backup"
    	FileUtils.cp(copy_from, copy_to)

    	bib_line = "\\BibliographySisyphus{#{bib.global_id}} % take this line out on new report";
    	tex.insert_bib_line(bib_line)
    	tex.save(texfilename)
      #Scan.process_file(texfilename, verbose)
        print "hint:\n"
        print " latexmk report\n"
        print " reducepdf report\n"
        print " pmlatex commit report\n"
    end
  end
end
