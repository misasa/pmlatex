require 'spec_helper'

RSpec.describe 'Test configuration isolation' do
  it 'ignores a configuration in the calling directory while loading the test helper' do
    File.write('.orochirc', "---\nuri: https://sentinel.invalid/\nuser: caller-sentinel\npassword: fake-only\n")
    helper = File.expand_path('spec_helper.rb', __dir__)
    # Older Ruby/Bundler pairs do not let the child process see gems that Bundler
    # installs outside the gem home (git or path sources), so load the bundle first.
    bundler_setup = defined?(Bundler) ? ['-rbundler/setup'] : []
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, '-I', File.expand_path('../lib', __dir__), *bundler_setup, '-rrspec/core', '-r', helper,
      '-e', "puts MedusaRestClient.config.fetch('user')")
    expect(status.success?).to be(true), stderr
    expect(stdout).to eq("test\n")
  end
end
