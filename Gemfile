source 'https://rubygems.org'

if ENV['MEDUSA_REST_CLIENT_FROM_GITHUB']
  # CI: GitHub-hosted runners cannot reach the university gem server, so the
  # Medusa client is taken from its public GitHub repository instead.
  gem 'medusa_rest_client', '~> 1.0',
      git: 'https://github.com/misasa/medusa_rest_client.git', tag: '1.5.2'
else
  # The Medusa client is distributed by the university, over HTTPS.
  source 'https://dream.misasa.okayama-u.ac.jp/rubygems/' do
    gem 'medusa_rest_client', '~> 1.0'
  end
end

gemspec
