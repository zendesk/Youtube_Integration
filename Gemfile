# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.0'

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'vcr'
  gem 'webmock'
end

group :test, :development do
  gem 'dotenv'
  gem 'rubocop'
end

gem 'any_channel_json_schemas'
gem 'google-api-client', git: 'https://github.com/HsuTimothy/google-api-ruby-client.git', branch: 'hardcode_timeout'
gem 'json'
gem 'json-schema'
gem 'sinatra'
gem 'airbrake', '~> 6.2'
