require 'rubygems'
require 'sinatra'
require 'json'
require 'json-schema'
require 'any_channel_json_schemas'
require_relative './controllers/manifest_controller'
require_relative './controllers/pull_controller'
require_relative './controllers/admin_controller'

class YoutubeIntegration < Sinatra::Base
	register Controllers::ManifestController
	register Controllers::PullController
	register Controllers::AdminController
	
	get '/' do
		"Hello World!"		
	end
end
