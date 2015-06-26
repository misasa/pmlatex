module Pmlatex
  class TexLog
    attr_accessor :filename, :src, :include_files
    def self.extract_tex_path(line)
        paths = []
        if line =~ /\((\S+\.tex)/
          p line
          group = Regexp.last_match
          p group
          p group[0]
          paths << group[1]
          return paths
        end

        #tex_path = line.gsub(/\(/,"").chomp if line =~ /\.tex/
    end

    def self.scan_tex_path(src)
      return unless src
      tokens = src.scan(/\(\S+\.tex/).uniq
      tokens.map{|token| token.sub(/\(/,'')} if tokens
    end

    def initialize(tex, verbose=false)
      @src = tex
      @verbose = verbose
    end
        
    def self.from_file(filename, verbose = false)
      #src = File.open(filename).read
      f = open(filename)
      src = f.read
      f.close
      src_utf8 = Pmlatex.to_utf_8(src)
      log = self.new(src_utf8, verbose)
      #tex.verbose = verbose
      log.filename = filename
      log.parse
      log
    end

    def parse
      @include_files = []
      paths = self.class.scan_tex_path(@src)
      
      paths.each do |tex_path|
        tex_path = Util.cygpath(tex_path, "m") if RUBY_PLATFORM.downcase =~ /cygwin/
        @include_files << tex_path
      end

      # Pmlatex.to_utf_8(src).split("\n").each do |line|
      #   self.class.extract_tex_path(line)
      #   tex_path = line.gsub(/\(/,"").chomp if line =~ /\.tex/
      #   next unless tex_path
      #   tex_path = tex_path.strip
      #   tex_path = Util.cygpath(tex_path, "m") if RUBY_PLATFORM.downcase =~ /cygwin/
      #   @include_files << tex_path
      # end
      # @include_files.shift
    end
    
  end
end