# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

ENV['RACK_ENV'] = 'test'
Bundler.require :default, ENV['RACK_ENV'].to_sym
Dotenv.load
require_relative '../app'

module RSpecMixin
  include Rack::Test::Methods
  def app
    YoutubeIntegration
  end
end

WebMock.disable_net_connect!
RSpec.configure do |c| 
  c.include RSpecMixin
  c.before(:all) { puts app.inspect } 
end

def metadata_with_invalid_auth_credentials
  {
    'credentials': {
      "authorization_uri": "https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=779541226128-btgh4e3kfgp6mjn41o3iiegd12pnq3ah.apps.googleusercontent.com&redirect_uri=https://0bba4895.ngrok.io/youtube_auth&response_type=code&scope=https://www.googleapis.com/auth/youtube.force-ssl",
    "token_credential_uri": "https://accounts.google.com/o/oauth2/token",
    "client_id": "779541226128-btgh4e3kfgp6mjn41o3iiegd12pnq3ah.apps.googleusercontent.com",
    "client_secret": "zzz",
    "scope": ["https://www.googleapis.com/auth/youtube.force-ssl"],
    "state": nil,
    "code": 'abc',
    "redirect_uri": "https://0bba4895.ngrok.io/youtube_auth",
    "username": nil,
    "password": nil,
    "issuer": nil,
    "audience": nil,
    "person": nil,
    "expiry": 60,
    "expires_at": 1499809779,
    "signing_key": nil,
    "refresh_token": nil,
    "access_token": "xD",
    "id_token": nil
    }.to_json
  }.to_json
end

def metadata_with_valid_credentials
  {
    'credentials': {
      "authorization_uri": "https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=779541226128-btgh4e3kfgp6mjn41o3iiegd12pnq3ah.apps.googleusercontent.com&redirect_uri=https://0bba4895.ngrok.io/youtube_auth&response_type=code&scope=https://www.googleapis.com/auth/youtube.force-ssl",
        "token_credential_uri": "https://accounts.google.com/o/oauth2/token",
        "client_id": "779541226128-btgh4e3kfgp6mjn41o3iiegd12pnq3ah.apps.googleusercontent.com",
        "client_secret": "wCqdW05ugx9dq5g1oumsP72o",
        "scope": ["https://www.googleapis.com/auth/youtube.force-ssl"],
        "state": nil,
        "code": nil,
        "redirect_uri": "https://0bba4895.ngrok.io/youtube_auth",
        "username": nil,
        "password": nil,
        "issuer": nil,
        "audience": nil,
        "person": nil,
        "expiry": 60,
        "expires_at": 1500059705,
        "signing_key": nil,
        "refresh_token": "1/iGuw-WtIrjC8dXXbjq8buFGx1uWhJ2RR7yGALifdda4",
        "access_token": "ya29.GluHBLab3V8-zxaPAN3xGR9XToVWSdk49KHTRWBMlV6Lm9C5co6ZM16TDZ5OSATxF6UAGEmFsSaKS2K9_c95uzS3ighokPNG0kEYycSxMCDxSCmTJMbowZGJj4Bw",
        "id_token": nil,
      }.to_json
  }.to_json
end
