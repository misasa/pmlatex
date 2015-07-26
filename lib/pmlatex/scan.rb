module Pmlatex
  class Scan < Cui
    # attr_accessor :cmd_opts, :global_opts
    # def initialize(output, global_opts = {}, cmd_opts = {})
    #   @output = output
    #   @cmd_opts = cmd_opts
    #   @global_opts = global_opts
    # end
    
    # def verbose
    #   @global_opts[:verbose]
    # end

    def cmd_options(argv=ARGV)
      Trollop::options(argv) do
        banner "  Usage: pmlatex scan mylocalfile"
        banner <<EOS
Usage: pmlatex scan mylocalfile
See `pmlatex --help'
EOS
      end
    end


    def self.rcheck_cite(ids, tex)
      if tex.include_files.empty?
        return ids.concat(check_cite(tex))
      else
        tex.include_files.each do |include_file|
          include_filename = include_file + '.tex'
          begin
            include_tex = Tex.from_file(include_filename, verbose)
            rcheck_cite(ids, include_tex)
          rescue => ex
            puts "Warning: #{ex}"
          end
        end
        return ids.concat(check_cite(tex))
      end
    end

    def self.check_cite(tex)
      ids = []
      [tex.citeyearpars, tex.citeps, tex.cites].flatten.each do |cite|
        begin
    		  print "ID:#{cite}"
    		  obj = MedusaRestClient::Record.find(cite)
          print " OK\n"
          ids << cite if obj
        rescue => ex
          puts " NG"
        end
      end
      return ids
    end

    def self.parse_texlog(fname, verbose = false)
      log = TexLog.from_file(fname, verbose)
    end

    def self.process_file(fname, verbose = false)
      #fname = ARGV.shift
      extlist = ['.tex', '.pdf']
      basename = File.basename(fname, ".*")
      dirname = File.dirname(fname)
      texfilename = File.join(dirname, basename + '.tex')
      logfilename = File.join(dirname, basename + '.log')
      pdffilename = File.join(dirname, basename + '.pdf')
      ssfilename = File.join(dirname, basename + '.ss')
      raise "Error: A local source-file <#{texfilename}> was not found. This message is generated" unless File.exist?(texfilename);
      raise "Error: An expected PDF-file <#{pdffilename}> was not found. Compile the source file <#{texfilename}> and have the PDF file <#{pdffilename}>. This message is generated" unless File.exist?(pdffilename);
      
      if verbose
#        print "#{year}/#{mon}/#{mday}\n";
      	print "basename: ", basename,"\n";
      	print "tex: ", texfilename,"\n";
      	print "pdf: ", pdffilename,"\n";
      end
      tex = Tex.from_file(texfilename, verbose)
      
      unless tex.bib_id
        raise "Error: A line that contains |BibliographySisyphus| was not found in the source file <#{texfilename}>. Try to correlated the file with Medusa by |pmlatex add #{texfilename}|. This message is generated";
  		end
  		
      bib = nil
  		begin
  		  print "bib-ID:#{tex.bib_id}"
  		  bib = MedusaRestClient::Record.find(tex.bib_id)
        print " OK\n"
      rescue => ex
        puts " NG"
        raise "Error: bib-ID:#{tex.bib_id} was not found on database."
      end
      
      ids = []
      #ids.concat(check_cite(tex))
      # [tex.citeyearpars, tex.citeps, tex.cites].flatten.each do |cite|
      #   check_cite(cite)
      # end      
      rcheck_cite(ids, tex)
      if File.exists?(logfilename)
        log = parse_texlog(logfilename)
        log.include_files.each do |include_filename|
          p "#{include_filename} is parsing..."
          include_tex = Tex.from_file(include_filename, verbose)
          ids = ids.concat(check_cite(include_tex))
        end
      end

      linked_ids = bib.relatives.map(&:global_id)
      unless ids.empty?
        ids.uniq!
        ids.each do |id|
          if linked_ids.include?(id)
            print "#{id} is already linked.\n"            
            next
          end
          begin
            print "#{id} is linking..."
            obj = MedusaRestClient::Record.find(id)
            obj.relatives << bib
            print " OK\n"
          rescue => ex
            print " NG\n"
          end
        end
        puts "#{ssfilename} writing..."
        @out = File.open(ssfilename, "w")
        @out.puts tex.bib_id
        @out.puts "parent"
        ids.each do |id|
          @out.puts id
        end
        @out.puts "children -y"
        @out.close
      end
      
    end
    def start
      raise "invalid args" unless argv.size > 0

      fname = argv.shift
      process_file(fname)
    end

    def process_file(fname)
      self.class.process_file(fname, verbose)
    end
  end
end
