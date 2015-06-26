module Pmlatex
  class Cui < App
    attr_accessor :output, :cmd_opts, :argv
    
    def initialize(output, argv = ARGV)
      @output = output
      @cmd_opts = cmd_options(argv)
      @argv = argv
    end
    
    def verbose
      global_opts[:verbose]
    end

  end
end