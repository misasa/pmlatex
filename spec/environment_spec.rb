require 'spec_helper'

RSpec.describe 'Test configuration isolation' do
  it 'ignores a configuration in the calling directory while loading the test helper' do
    File.write('.orochirc', "---\nuri: https://sentinel.invalid/\nuser: caller-sentinel\npassword: fake-only\n")
    helper = File.expand_path('spec_helper.rb', __dir__)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, '-I', File.expand_path('../lib', __dir__), '-rrspec/core', '-r', helper,
      '-e', "puts MedusaRestClient.config.fetch('user')")
    expect(status.success?).to be(true), stderr
    expect(stdout).to eq("test\n")
  end
end
