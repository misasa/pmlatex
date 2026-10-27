require 'spec_helper'

RSpec.describe 'Command-line entry point' do
  let(:root) { File.expand_path('../..', __dir__) }

  def run_cli(*args)
    File.write('.orochirc', "---\nuri: https://medusa.invalid/\nuser: test\npassword: test\n")
    Open3.capture3({'HOME' => Dir.pwd}, RbConfig.ruby, '-I', File.join(root, 'lib'), File.join(root, 'bin/pmlatex'), *args)
  end

  it 'shows global help with a successful exit without changing input files' do
    write_report
    original = File.binread('report.tex')
    stdout, stderr, status = run_cli('--help')
    expect(status.success?).to be(true), stderr
    expect(stdout).to include('Usage: pmlatex', 'add commit update scan')
    expect(File.binread('report.tex')).to eq(original)
    expect(Dir['*.backup', '*.ss']).to be_empty
  end

  %w[add commit update scan].each do |subcommand|
    it "shows #{subcommand} help without contacting Medusa" do
      stdout, stderr, status = run_cli(subcommand, '--help')
      expect(status.success?).to be(true), stderr
      expect(stdout).to include("Usage: pmlatex #{subcommand}")
    end

    it "fails #{subcommand} for missing input before a remote operation" do
      _, stderr, status = run_cli(subcommand, 'absent.tex')
      expect(status.success?).to be(false)
      expect(stderr).to include('not found')
      expect(Dir['*.backup', '*.ss']).to be_empty
    end
  end

  it 'fails for an unknown subcommand' do
    _, stderr, status = run_cli('unknown')
    expect(status.success?).to be(false)
    expect(stderr).to include('not implemented')
  end
end
