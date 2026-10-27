require 'spec_helper'
require 'json'
require 'digest'

RSpec.describe 'Release preflight' do
  let(:script) { File.expand_path('../script/verify_release.rb', __dir__) }

  def git(*args)
    stdout, stderr, status = Open3.capture3('git', *args)
    raise stderr unless status.success?
    stdout.strip
  end

  before do
    git('init', '-q')
    File.write('pmlatex.gemspec', <<~'RUBY')
      Gem::Specification.new do |spec|
        spec.name = 'pmlatex'
        spec.version = '1.2.3'
      end
    RUBY
    git('add', '.')
    git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'fixture')
    git('tag', 'v1.2.3')
    git('update-ref', 'refs/remotes/origin/master', 'HEAD')
    @commit = git('rev-parse', 'HEAD')
    File.write('releases.json', '[[]]')
  end

  def preflight(tag = 'v1.2.3', commit = @commit)
    Open3.capture3(RbConfig.ruby, script, tag, commit, 'releases.json')
  end

  it 'returns the asset filename only after validating tag, commit, version and master ancestry' do
    stdout, stderr, status = preflight
    expect(status.success?).to be(true), stderr
    expect(stdout).to eq("pmlatex-1.2.3.gem\n")
  end

  it 'rejects a tag that does not match the package version' do
    _, stderr, status = preflight('v9.9.9')
    expect(status.success?).to be(false)
    expect(stderr).to include('Tag version differs')
  end

  it 'rejects an event commit that does not match the checkout' do
    _, stderr, status = preflight('v1.2.3', '0' * 40)
    expect(status.success?).to be(false)
    expect(stderr).to include('commit differ')
  end

  it 'rejects a tag pointing to an older commit even when the event and checkout match' do
    git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '--allow-empty', '-qm', 'later commit')
    checkout = git('rev-parse', 'HEAD')
    git('update-ref', 'refs/remotes/origin/master', checkout)
    _, stderr, status = preflight('v1.2.3', checkout)
    expect(status.success?).to be(false)
    expect(stderr).to include('commit differ')
  end

  it 'rejects a commit unrelated to an existing master reference' do
    unrelated = git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
                    'commit-tree', 'HEAD^{tree}', '-m', 'unrelated root')
    git('update-ref', 'refs/remotes/origin/master', unrelated)
    _, stderr, status = preflight
    expect(status.success?).to be(false)
    expect(stderr).to include('not contained')
  end

  it 'rejects a release commit outside master' do
    git('update-ref', '-d', 'refs/remotes/origin/master')
    _, stderr, status = preflight
    expect(status.success?).to be(false)
    expect(stderr).to include('not contained')
  end

  it 'rejects a previously used legacy unprefixed tag' do
    git('tag', '1.2.3')
    _, stderr, status = preflight
    expect(status.success?).to be(false)
    expect(stderr).to include('Legacy version tag already exists')
  end

  [
    {'tag_name' => 'v1.2.3', 'draft' => true, 'assets' => []},
    {'tag_name' => '1.2.3', 'assets' => []},
    {'tag_name' => 'v0.1.0', 'assets' => [{'name' => 'pmlatex-1.2.3.gem'}]}
  ].each_with_index do |release, index|
    it "rejects existing version or asset collision #{index + 1}, including drafts" do
      File.write('releases.json', JSON.generate([[], [release]]))
      _, stderr, status = preflight
      expect(status.success?).to be(false)
      expect(stderr).to include('already exists')
    end
  end

  it 'fails closed on a malformed API response' do
    File.write('releases.json', '{"message":"API failed"}')
    _, stderr, status = preflight
    expect(status.success?).to be(false)
    expect(stderr).to include('Invalid Release API response')
  end
end

RSpec.describe 'Public release download' do
  let(:script) { File.expand_path('../script/download_release.sh', __dir__) }

  before do
    FileUtils.mkdir_p(['tools', 'assets'])
    File.write('assets/pmlatex-1.2.3.gem', 'release fixture bytes')
    digest = Digest::SHA256.file('assets/pmlatex-1.2.3.gem').hexdigest
    File.write('assets/pmlatex-1.2.3.gem.sha256', "#{digest}  pmlatex-1.2.3.gem\n")
    # Simulated transport only: no credentials, remote deployment or HTTP request.
    File.write('tools/curl', "#!#{RbConfig.ruby}\n" + <<~'RUBY')
      require 'fileutils'
      File.open(ENV.fetch('TRACE'), 'a') { |file| file.puts(ARGV.last) }
      output = ARGV[ARGV.index('--output') + 1]
      if ARGV.last.end_with?('/latest')
        abort 'No release' if ENV['NO_RELEASE']
        print 'https://github.com/misasa/pmlatex/releases/tag/v1.2.3'
      else
        name = File.basename(ARGV.last)
        if ENV['RACE_DEST'] && !File.exist?(ENV['RACE_DEST'])
          Dir.mkdir(ENV['RACE_DEST'])
        end
        abort 'Missing asset' if ENV['MISSING_ASSET'] == name
        FileUtils.cp(File.join(ENV.fetch('ASSETS'), name), output)
      end
    RUBY
    %w[ssh scp].each do |tool|
      File.write("tools/#{tool}", "#!#{RbConfig.ruby}\n" + <<~'RUBY')
        tool = File.basename($0)
        File.open(ENV.fetch('TRACE'), 'a') { |file| file.puts([tool, *ARGV].join(' ')) }
        abort "Simulated #{tool} failure" if ENV['FAIL_TRANSPORT'] == tool
      RUBY
    end
    FileUtils.chmod(0755, Dir['tools/*'])
    @environment = {'PATH' => "#{Dir.pwd}/tools:#{ENV.fetch('PATH')}", 'ASSETS' => "#{Dir.pwd}/assets", 'TRACE' => "#{Dir.pwd}/trace"}
  end

  def download(*args, env: {})
    Open3.capture3(@environment.merge(env), 'bash', script, '--output-dir', 'downloads', *args)
  end

  it 'downloads the latest public release and verifies both saved assets' do
    stdout, stderr, status = download
    expect(status.success?).to be(true), stderr
    expect(stdout).to include('Verified:')
    %w[pmlatex-1.2.3.gem pmlatex-1.2.3.gem.sha256].each do |name|
      expect(File.binread("downloads/#{name}")).to eq(File.binread("assets/#{name}"))
    end
    expect(File.read('trace')).to include('/latest', '/download/v1.2.3/pmlatex-1.2.3.gem')
  end

  it 'accepts a pinned v-prefixed version without a latest lookup' do
    _, stderr, status = download('--version', 'v1.2.3')
    expect(status.success?).to be(true), stderr
    expect(File.read('trace')).not_to include('/latest')
  end

  it 'rejects a checksum mismatch without exposing a downloaded gem' do
    File.write('assets/pmlatex-1.2.3.gem', 'tampered')
    _, stderr, status = download('--version', '1.2.3')
    expect(status.success?).to be(false)
    expect(stderr).to include('SHA-256 mismatch')
    expect(Dir['downloads/*', 'downloads/.pmlatex-*']).to be_empty
  end

  it 'rejects an unsafe or extra manifest entry' do
    File.open('assets/pmlatex-1.2.3.gem.sha256', 'a') { |file| file.puts('0  ../../unsafe') }
    _, stderr, status = download('--version', '1.2.3')
    expect(status.success?).to be(false)
    expect(stderr).to include('invalid checksum manifest')
  end

  it 'leaves existing files unchanged and avoids the asset download' do
    FileUtils.mkdir_p('downloads')
    File.write('downloads/pmlatex-1.2.3.gem', 'keep me')
    _, stderr, status = download('--version', '1.2.3')
    expect(status.success?).to be(false)
    expect(stderr).to include('Destination already exists')
    expect(File.read('downloads/pmlatex-1.2.3.gem')).to eq('keep me')
    expect(File.exist?('trace')).to be(false)
  end

  it 'rejects dangling symlinks as existing destinations' do
    FileUtils.mkdir_p('downloads')
    File.symlink('absent', 'downloads/pmlatex-1.2.3.gem')
    _, stderr, status = download('--version', '1.2.3')
    expect(status.success?).to be(false)
    expect(stderr).to include('Destination already exists')
    expect(File.symlink?('downloads/pmlatex-1.2.3.gem')).to be(true)
  end

  %w[pmlatex-1.2.3.gem pmlatex-1.2.3.gem.sha256].each do |name|
    it "fails if #{name} becomes a directory during download" do
      destination = File.join(Dir.pwd, 'downloads', name)
      stdout, _, status = download('--version', '1.2.3', env: {'RACE_DEST' => destination})
      expect(status.success?).to be(false)
      expect(stdout).not_to include('Verified:')
      expect(Dir.children(destination)).to be_empty
    end
  end

  it 'fails if the latest release cannot be found' do
    _, stderr, status = download(env: {'NO_RELEASE' => '1'})
    expect(status.success?).to be(false)
    expect(stderr).to include('Cannot find a public stable Release')
    expect(File.exist?('downloads')).to be(false)
  end

  it 'fails if either asset is absent and cleans temporary files' do
    _, stderr, status = download('--version', '1.2.3', env: {'MISSING_ASSET' => 'pmlatex-1.2.3.gem.sha256'})
    expect(status.success?).to be(false)
    expect(stderr).to include('Cannot download')
    expect(Dir['downloads/*', 'downloads/.pmlatex-*']).to be_empty
  end

  ['../1.2.3', '1.2.3-rc1', '01.2.3'].each do |version|
    it "rejects invalid version #{version.inspect} before transport" do
      _, _, status = download('--version', version)
      expect(status.success?).to be(false)
      expect(File.exist?('trace')).to be(false)
    end
  end

  it 'does not deploy merely because a destination is set' do
    _, stderr, status = download('--version', '1.2.3', env: {'PMLATEX_DEPLOY_DEST' => 'user@host:/srv/gems'})
    expect(status.success?).to be(true), stderr
    expect(File.read('trace')).not_to include('ssh ', 'scp ')
  end

  it 'requires an explicit valid destination when deployment is requested' do
    _, stderr, status = download('--deploy', env: {'PMLATEX_DEPLOY_DEST' => 'user@host:/bad;command'})
    expect(status.success?).to be(false)
    expect(stderr).to include('Set PMLATEX_DEPLOY_DEST')
    expect(File.exist?('trace')).to be(false)
  end

  it 'stops before copying if the remote version directory cannot be created' do
    stdout, stderr, status = download('--version', '1.2.3', '--deploy', env: {
      'PMLATEX_DEPLOY_DEST' => 'user@host:/srv/gems', 'FAIL_TRANSPORT' => 'ssh'
    })
    expect(status.success?).to be(false)
    expect(stderr).to include('Cannot create remote directory')
    expect(File.read('trace')).to include('ssh ')
    expect(File.read('trace')).not_to include('scp ')
    expect(stdout).not_to include('Copied to:')
    expect(File.binread('downloads/pmlatex-1.2.3.gem')).to eq('release fixture bytes')
  end

  it 'reports a failed copy without claiming deployment succeeded or losing local verified files' do
    stdout, stderr, status = download('--version', '1.2.3', '--deploy', env: {
      'PMLATEX_DEPLOY_DEST' => 'user@host:/srv/gems', 'FAIL_TRANSPORT' => 'scp'
    })
    expect(status.success?).to be(false)
    expect(stderr).to include('Transfer failed')
    expect(File.read('trace')).to include('scp ')
    expect(stdout).not_to include('Copied to:')
    %w[pmlatex-1.2.3.gem pmlatex-1.2.3.gem.sha256].each do |name|
      expect(File.binread("downloads/#{name}")).to eq(File.binread("assets/#{name}"))
    end
  end

  it 'reserves a new remote version directory before copying only the verified files' do
    _, stderr, status = download('--version', '1.2.3', '--deploy', env: {'PMLATEX_DEPLOY_DEST' => 'user@host:/srv/gems'})
    expect(status.success?).to be(true), stderr
    trace = File.read('trace')
    expect(trace).to include("ssh -oBatchMode=yes user@host mkdir '/srv/gems/v1.2.3'")
    expect(trace).to include('pmlatex-1.2.3.gem.sha256 user@host:/srv/gems/v1.2.3/')
    expect(trace.index('ssh ')).to be < trace.index('scp ')
  end
end
