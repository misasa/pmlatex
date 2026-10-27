require 'tmpdir'
require 'fileutils'
require 'stringio'
require 'open3'
require 'rbconfig'

# The client reads configuration while loading. Never read or write user credentials.
Dir.mktmpdir('pmlatex-spec-home-') do |home|
  previous_home = ENV['HOME']
  ENV['HOME'] = home
  File.write(File.join(home, '.orochirc'), "---\nuri: https://medusa.invalid/\nuser: test\npassword: test\n")
  begin
    Dir.chdir(home) { require 'pmlatex' }
  ensure
    ENV['HOME'] = previous_home
  end
end
require 'webmock/rspec'
WebMock.disable_net_connect!

module SpecFiles
  def fixture(name)
    File.expand_path("fixtures/files/#{name}", __dir__)
  end

  def document(bib_id: 'bib-1', title: 'Example report', author: 'Yusuke Yachi', date: '2014-04-05')
    text = "\\documentclass{article}\n\\title{#{title}}\n\\author{#{author}}\n\\date{#{date}}\n\\begin{document}\n\\maketitle\n"
    text += "\\BibliographySisyphus{#{bib_id}}\n" if bib_id
    text + "\\end{document}\n"
  end

  def write_report(text = document)
    File.write('report.tex', text)
    FileUtils.cp(fixture('template.pdf'), 'report.pdf')
  end

  def command(klass, args = ['report.tex'])
    klass.new(StringIO.new, args.dup)
  end
end

RSpec.configure do |config|
  config.include SpecFiles
  config.order = :random
  config.raise_errors_for_deprecations!
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
  config.around do |example|
    previous_options = Pmlatex::App.global_opts.dup
    Pmlatex::App.global_opts = {verbose: false}
    Dir.mktmpdir('pmlatex-spec-') do |directory|
      Dir.chdir(directory) { example.run }
    end
  ensure
    Pmlatex::App.global_opts = previous_options
  end
end
