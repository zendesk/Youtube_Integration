module Controllers
	module ChannelbackController
		## Provides requester with an html page to configure
        ## the instance of Youtube into AnyChannel
		def self.registered(app)
			app.post '/channelback' do
				# STUFF HERE
				metadata = JSON.parse(params[:metadata])
				client_opts = JSON.parse(metadata["credentials"])
				auth_client = Signet::OAuth2::Client.new(client_opts)
				auth_client.fetch_access_token! 							# Refreshes my access token
				service = Google::Apis::YoutubeV3::YouTubeService.new
				service.authorization = auth_client
				
				message = params[:message]
				channel_id = JSON.parse(metadata["channel_id"])
				service.insert_comment('snippet', {'snippet.parent_id': '', 'snippet.text_original': ''}, )

				{
				  "external_id": "20151210123400-coolyoutubeguy",
				  "allow_channelback": true
				}.to_json
			end
		end
	end
end
