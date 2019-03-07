module Pmlatex
  class Update < Cui
    
    def cmd_options(argv=ARGV)
      Optimist::options(argv) do
        # banner "  Usage: pmlatex update mylocalfile"
        banner <<EOS
Usage: pmlatex update mylocalfile
See `pmlatex --help'
EOS
      end
    end

    def start
      raise "invalid args" unless argv.size > 0

      fname = argv.shift
      process_file(fname)
    end

    def process_file(fname)
      extlist = ['.tex', '.pdf']
      basename = File.basename(fname, ".*")
      dirname = File.dirname(fname)
      texfilename = File.join(dirname, basename + '.tex')
      pdffilename = File.join(dirname, basename + '.pdf')

      # texfilename = basename + '.tex'
      # pdffilename = basename + '.pdf'
      raise "Error: A local source-file <#{texfilename}> was not found. This message is generated" unless File.exist?(texfilename);
      raise "Error: An expected PDF-file <#{pdffilename}> was not found. Compile the source file <#{texfilename}> and have the PDF file <#{pdffilename}>. This message is generated" unless File.exist?(pdffilename);
      
      tex = Tex.from_file(texfilename, verbose)
      unless tex.bib_id
        raise "Error: A line that contains |BibliographySisyphus| was not found in the source file <#{texfilename}>. Try to correlated the file with Medusa by |pmlatex add #{texfilename}|. This message is generated";
  		end

      tex.parse_author  		
      authors = []
      tex.author_fullnames.each do |author_name|
        authors << MedusaRestClient::Author.find_or_create_by_name(author_name)
      end
      author_list = authors.map(&:name).join(' and ')

  		bib = MedusaRestClient::Record.find(tex.bib_id)
      bib_authors = []
      bib.author_ids.each do |author_id|
        bib_authors << MedusaRestClient::Author.find(author_id)
      end
      bib_author_list = bib_authors.map(&:name).join(' and ')

  		return if (tex.title == bib.name && authors == bib_authors && tex.year.to_s == bib.year.to_s && tex.mon.to_s == bib.month.to_s)
      
      msg = "Are you sure you want to update a record <Bib: #{bib.global_id}> in following manner?\n"; 
    	msg += "from: #{bib.name} by #{bib_author_list} on #{bib.year}/#{bib.month}\n"
    	msg += "to  : #{tex.title} by #{author_list} on #{tex.year}/#{tex.mon}\n";
    	STDERR.puts msg;
    	# STDERR.puts "(y/n [y]) "
    	print "[Y/n] "
        user_input = STDIN.gets.chomp
      user_input = "y" if user_input.blank?
      if user_input[0].chr.downcase == "y"
        bib.name = tex.title 
        bib.author_ids = authors.map(&:id)
        bib.year = tex.year if tex.year
        bib.volume = tex.year - 2000 if tex.year
        bib.month = tex.mon if tex.mon
        bib.pages = bib.global_id
        bib.save
        bib.reload
    		output = "The bibliography record <#{bib.global_id}> was updated to be #{bib.name} by #{bib_author_list} on #{bib.year}/#{bib.month}."
    		STDERR.puts output	
      end
      print "Hint:\n"
      print " latexmk report\n"
      print " reducepdf report\n"
      print " pmlatex commit report\n"
    end
  end
end
