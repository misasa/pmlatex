# Run under Bundler. Install only this archive; reuse precisely resolved dependencies.
require 'bundler'
require 'rubygems/package'
require 'rbconfig'
require 'open3'
require 'tmpdir'
require 'fileutils'
require 'digest'
require_relative '../lib/pmlatex/version'

root = File.expand_path('..', __dir__)
archive = File.expand_path(ARGV.fetch(0))
package = Gem::Package.new(archive)
raise 'Invalid gem archive' unless package.verify
spec = package.spec
raise 'Package version differs from source' unless spec.version.to_s == Pmlatex::VERSION
raise 'Wrong package name' unless spec.name == 'pmlatex'
expected_files = Dir.chdir(root) { %w[README.md LICENSE.txt bin/pmlatex] + Dir['lib/**/*.rb'] }
raise 'Unexpected or missing packaged files' unless package.contents.sort == expected_files.sort
raise 'Wrong executable metadata' unless spec.executables == ['pmlatex']
raise 'Wrong license metadata' unless spec.licenses == ['GPL-3.0-or-later']
raise 'Wrong Ruby floor' unless spec.required_ruby_version.to_s == '>= 2.6.0'

# A new gem home contains only the resolved dependency versions. No access to
# unrelated installed gems, and no download or change to the user's gem home.
dependencies = Bundler.load.specs.reject { |dependency| %w[pmlatex bundler].include?(dependency.name) }
Dir.mktmpdir('pmlatex-package-') do |directory|
  extracted = File.join(directory, 'archive')
  package.extract_files(extracted)
  expected_files.each do |path|
    raise "Archive differs from source: #{path}" unless Digest::SHA256.file(File.join(extracted, path)).hexdigest == Digest::SHA256.file(File.join(root, path)).hexdigest
  end
  home = File.join(directory, 'gems')
  FileUtils.mkdir_p([File.join(home, 'gems'), File.join(home, 'specifications')])
  dependencies.each do |dependency|
    FileUtils.ln_s(dependency.full_gem_path, File.join(home, 'gems', dependency.full_name))
    File.write(File.join(home, 'specifications', "#{dependency.full_name}.gemspec"), dependency.to_ruby)
    if dependency.extensions.any?
      target = File.join(home, 'extensions', Gem::Platform.local.to_s, Gem.extension_api_version, dependency.full_name)
      FileUtils.mkdir_p(File.dirname(target))
      FileUtils.ln_s(dependency.extension_dir, target)
    end
  end

  File.write(File.join(directory, '.orochirc'), "---\nuri: https://medusa.invalid/\nuser: test\npassword: test\n")
  environment = {'HOME' => directory, 'GEM_HOME' => home, 'GEM_PATH' => home, 'RUBYLIB' => nil, 'RUBYOPT' => nil}
  execute = lambda do |*arguments|
    stdout, stderr, status = Open3.capture3(environment, RbConfig.ruby, *arguments, chdir: directory)
    raise "Command failed (#{status.exitstatus}): #{arguments.inspect}\n#{stdout}\n#{stderr}" unless status.success?
    stdout
  end
  Bundler.with_unbundled_env do
    execute.call('-rrubygems/gem_runner', '-e', 'Gem::GemRunner.new.run(ARGV)', '--',
                 'install', '--local', '--no-document', '--ignore-dependencies', archive)
    check = <<~'RUBY'
      require 'pmlatex'
      spec = Gem.loaded_specs.fetch('pmlatex')
      abort 'Wrong installed version' unless Pmlatex::VERSION == ARGV.fetch(0)
      abort 'Wrong installation directory' unless File.realpath(spec.base_dir) == File.realpath(ENV.fetch('GEM_HOME'))
      feature = $LOADED_FEATURES.find { |path| path.end_with?('/lib/pmlatex.rb') }
      abort 'Loaded source instead of installed gem' unless feature == File.join(spec.full_gem_path, 'lib/pmlatex.rb')
      tex = Pmlatex::Tex.new("\n\\title{Installed report}\n\\author{Yusuke Yachi}\n\\date{2014-04-05}\n\\BibliographySisyphus{bib-1}\n")
      tex.parse
      abort 'Installed parser failed' unless [tex.title, tex.bib_id, tex.author_fullnames, tex.year, tex.mon] == ['Installed report', 'bib-1', ['Yachi, Yusuke'], 2014, 4]
      paths = Pmlatex::TexLog.scan_tex_path('(./report.tex (./child.tex) (./report.tex)')
      abort 'Installed log parser failed' unless paths == ['./report.tex', './child.tex']
      abort 'Installed renderer failed' unless Pmlatex::OverPic.new.tick_for_circle(10, 20, 10, 0) == '\\qbezier(19.000,20.000)(19.500,20.000)(20.000,20.000)'
      puts Pmlatex::VERSION
    RUBY
    execute.call('-e', check, Pmlatex::VERSION)
    executable = File.join(home, 'bin', 'pmlatex')
    [[], ['add'], ['commit'], ['update'], ['scan']].each do |args|
      output = execute.call(executable, *args, '--help')
      raise 'Missing installed CLI help' unless output.include?('Usage: pmlatex')
    end
    raise 'Help created unexpected output' unless Dir[File.join(directory, '*.{tex,pdf,backup,ss}')].empty?
  end
end
puts "Verified archive and installed CLI: #{File.basename(archive)} (Ruby #{RUBY_VERSION})"
