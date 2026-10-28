# coding: utf-8
require_relative 'lib/pmlatex/version'

Gem::Specification.new do |spec|
  spec.name          = 'pmlatex'
  spec.version       = Pmlatex::VERSION
  spec.authors       = ['Yusuke Yachi']
  spec.email         = ['yyachi@misasa.okayama-u.ac.jp']
  spec.summary       = 'Upload pmlatex documents to Medusa'
  spec.description   = 'Create and update Medusa bibliography records, upload their PDFs, and link cited records from pmlatex documents.'
  spec.homepage      = 'https://github.com/misasa/pmlatex'
  spec.license       = 'GPL-3.0-or-later'
  spec.required_ruby_version = '>= 2.6.0'

  spec.files         = %w[LICENSE.txt README.md bin/pmlatex] + Dir['lib/**/*.rb'].sort
  spec.executables   = ['pmlatex']
  spec.require_paths = ['lib']

  spec.add_dependency 'medusa_rest_client', '~> 1.0'
  spec.add_dependency 'optimist', '~> 3.0'
  spec.add_development_dependency 'bundler', '>= 2.4.22', '< 5'
  spec.add_development_dependency 'rake', '>= 12.3.3', '< 14'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
