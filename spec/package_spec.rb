require 'spec_helper'

RSpec.describe 'Package contract' do
  let(:specification) do
    Dir.chdir(File.expand_path('..', __dir__)) { Gem::Specification.load('pmlatex.gemspec') }
  end

  it 'declares the license already granted by LICENSE.txt' do
    expect(specification.licenses).to eq(['GPL-3.0-or-later'])
  end

  it 'admits the two maintenance Rubies and excludes versions below the tested floor' do
    requirement = specification.required_ruby_version
    expect(requirement.satisfied_by?(Gem::Version.new('2.6.10'))).to be(true)
    expect(requirement.satisfied_by?(Gem::Version.new('4.0.9'))).to be(true)
    expect(requirement.satisfied_by?(Gem::Version.new('2.6.9'))).to be(false)
  end

  it 'packages runtime code, its executable, README and license without development files' do
    root = File.expand_path('..', __dir__)
    runtime = Dir.chdir(root) { Dir['lib/**/*.rb'].sort }
    expect(specification.files.sort).to eq((runtime + %w[bin/pmlatex README.md LICENSE.txt]).sort)
    expect(specification.executables).to eq(['pmlatex'])
  end
end
