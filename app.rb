require 'sinatra'

class YoutubeIntegration < Sinatra::Base
	get '/' do
		"Hello World!"		
	end

	get '/manifest' do
		content_type :json
		File.read('manifest.json.erb')
	end

	post '/pull' do
		puts params.inspect
		"pull page"
	end
end
