require "pmlatex/version"
require 'pmlatex/app'
require 'pmlatex/cui'
require 'pmlatex/add'
require 'pmlatex/scan'
require 'pmlatex/update'
require 'pmlatex/commit'
require 'pmlatex/tex'
require 'pmlatex/tex_log'
require 'pmlatex/tex_helper'
require 'pmlatex/overpic'
require 'medusa_rest_client'
require 'optimist'
require 'open3'
class Util
  def self.cygpath(filepath, option = "m")
    dirname = File.dirname(filepath)
    basename = File.basename(filepath)
    command = "cygpath -#{option} \"#{dirname}\""
    puts "#{command}..." if @verbose
      out, error, status = Open3.capture3(command)
      cpath = out.chomp
      return File.join(cpath, basename)
  end  
end

module Pmlatex
	def self.to_utf_8(str)
		str.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
	end
end
