module Pmlatex
  class Tex
    attr_accessor :filename, :src, :verbose, :bib_id, :title, :author, :authors, :year, :mon, :mday, :date, :citeyearpars, :citeps, :cites, :include_files
    def initialize(tex, verbose=false)
      @src = tex
      @verbose = verbose
    end
        
    def self.from_file(filename, verbose = false)
      #src = File.open(filename).read
      f = open(filename)
      src = f.read
      f.close
      tex = self.new(src, verbose)
      #tex.verbose = verbose
      tex.filename = filename
      tex.parse
      tex
    end
    
    def year
      return unless date
      date.year
    end
    
    def mon
      return unless date
      date.month
    end

    def mday
      day
    end

    def day
      return unless date
      date.day
    end
    
    def parse
      if src =~ /\n\\BibliographySisyphus\{(.+)\}/
      	@bib_id = $1;
      	print "bib_id: #{bib_id}\n" if verbose
      end
      
      if src =~ /\n\\title\{(.+?)\}/m
      	@title = $1;
      	print "title: #{title}\n" if verbose
      end

      if src =~ /\n\\author\{(.+)\}/
      	@author = $1;
      	print "author: #{author}\n" if verbose
      end

      if src =~ /\n\\date\{(.+)\}/
        begin
      	  @date = Time.parse($1)
      	rescue
      	  @date = Time.now
    	  end
      end
      
      @include_files = []
      src.split("\n").each do |line|
        next if line.empty?
        next if line =~ /^\%/
        @include_files.concat(line.scan(/\\include\{(.+)\}/).flatten)
        @include_files.concat(line.scan(/\\input\{(.+)\}/).flatten)
      end
      
      # @citeyearpars = src.scan(/\\citeyearpar\{(.+)\}/).flatten      
      # @citeps = src.scan(/\\citep\{(.+)\}/).flatten
      # @cites = src.scan(/\\cite\{(.+)\}/).flatten
      @citeyearpars = []
      @citeps = []
      @cites = []
      src.split("\n").each do |line|
        next if line.empty?
        next if line =~ /^\%/
        @citeyearpars.concat(line.scan(/\\citeyearpar\{(.+?)\}/).flatten)
        @citeps.concat(line.scan(/\\citep\{(.+?)\}/).flatten)
        @cites.concat(line.scan(/\\cite\{(.+?)\}/).flatten)
      end
      
    end

    def author_fullnames(delim = ', ')
      a = []
      parse unless @author
      parse_author unless @authors
      return a unless @authors
      @authors.each do |h|
        nameitems = [h[:lastname]]
        nameitems << h[:firstname] if h[:firstname]
        a << nameitems.join(delim)
      end
      a
    end

    def parse_author
      hs = []
      items = author.gsub(/,?\s*and\s*/,",").split(",")
      firsts = []
      lasts = []
      items.each do |key|
        key.gsub!(/^\s*/,"")
        key.gsub!(/\s*$/,"")
        if key =~ /\.$/
          #Yachi, Y.,
          firsts << key
        else
          vals = key.split(' ')
          if vals.size == 1
            #Yachi, Y.,
            lasts << vals[0]
          else
            #Yusuke Jr. Yachi
            lasts << vals[-1]
            firsts << vals[0...-1].join(' ')
          end
        end
      end

      if firsts.size == lasts.size
        lasts.size.times do |i|
          h = Hash.new
          h[:firstname] = firsts[i]
          h[:lastname] = lasts[i]
          hs << h
        end
      else
        lasts.size.times do |i|
          h = Hash.new
          h[:lastname] = lasts[i]
          hs << h
        end
      end
      @authors = hs
    end
  
    def insert_bib_line(bib_line)
      buf = src
      if src =~ /\n\% FILEPATH START/
    	 	buf = $` + "\n" + bib_line + $& + $';		
      elsif src =~ /\n\\maketitle/
    	 	buf = $` + $& + "\n" + bib_line + $';
    	elsif src =~ /\n\\begin\{document\}/
    		buf = $` + $& + "\n" + bib_line + $';
    	else
    		raise "Could not find \\begin{document} in #{@filename}.";
    	end
    	@src = buf
    end
        
    def save(filename)
      #File.open(filename, 'w').puts src
      f = open(filename, "w")
      f.puts src
      f.close
    end
  end
end