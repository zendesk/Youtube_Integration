require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require_relative '../app'

module RSpecMixin
	include Rack::Test::Methods
	def app
		YoutubeIntegration
	end
end

RSpec.configure { |c| c.include RSpecMixin }
