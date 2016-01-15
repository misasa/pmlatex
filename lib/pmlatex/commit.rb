module Pmlatex
  class Commit < Cui

    def cmd_options(argv=ARGV)
      Trollop::options(argv) do
        # banner "  Usage: pmlatex commit [options] mylocalfile"
        banner <<EOS
Usage: pmlatex commit [options] mylocalfile
See `pmlatex --help'
EOS
        opt :message, "specify log message", :type => :string
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
  		
  		obj = MedusaRestClient::Record.find(tex.bib_id)
      
      existing = nil
      obj.attachment_files.each do |at|
        # print "#{at.data_file_name} <#{at.class.element_name.capitalize}: #{at.global_id}>\n"
        existing = at if at.data_file_name == File.basename(pdffilename)
      end
      
      if existing
    		msg = "A " + obj.class.to_s + " record named |" + obj.name + "| <#{obj.global_id}> is already with file |#{pdffilename}| <Attachment:#{existing.global_id}>. Do you want to replace it? [Y/n/append] ";
    		print msg;
    		user_input =  STDIN.gets.chomp;
    	  STDERR.puts "you typed '#{user_input}'." if verbose;
    	  user_input = "y" if user_input.blank?
    	  case user_input[0].chr.downcase
    	    when "n"
    	      STDERR.puts "Your commitment was canceled."
    	      return
    	    when "a"

  	      else
        	  STDERR.puts "Replacing file |#{pdffilename}|..."
        	  existing.destroy
      	  end
    	end

      # md5hash = Digest::MD5.hexdigest(File.open(pdffilename).read)
      # Attachment.find(:all, :params => {:md5hash => md5hash}).each do |at|
      #   obj.link(at)
      # end

      # attachment = Attachment.new
      # attachment.file = pdffilename
      # attachment.save
      # attachment.reload
      # obj.link(attachment)
      obj.upload_file(:file => pdffilename)      
      if @cmd_opts[:message]
        svn_cmd = "svn commit -m #{@cmd_opts[:message]} #{fname}"
        system(svn_cmd)
      end
      print "hint:\n"
      print " latexmk -c #{basename}\n"
      print " icp commit\n"
    end
  end
end
