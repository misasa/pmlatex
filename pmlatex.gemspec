# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pmlatex/version'

Gem::Specification.new do |spec|
  spec.name          = "pmlatex"
  spec.version       = Pmlatex::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.summary       = %q{Pmlatex}
  spec.description   = %q{Pmlatex}
  spec.homepage      = "http://dream.misasa.okayama-u.ac.jp"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "medusa_rest_client", "~> 0.1.15"
  spec.add_dependency "optimist"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
#  spec.add_development_dependency "simplecov-rcov", "~> 0.2.3"
#  spec.add_development_dependency "rspec_junit_formatter", "~> 0.2.0"
end
