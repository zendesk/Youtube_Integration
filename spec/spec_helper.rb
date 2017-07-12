# frozen_string_literal: true

require 'rack/test'
require 'rspec'

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

RSpec.configure { |c| c.include RSpecMixin }
