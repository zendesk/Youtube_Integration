module Controllers
	module ChannelbackController
		## Provides requester with an html page to configure
        ## the instance of Youtube into AnyChannel
		def self.registered(app)
			app.post '/channelback' do
				# STUFF HERE
				{
				  "external_id": "20151210123400-coolyoutubeguy",
				  "allow_channelback": true
				}.to_json
			end
		end
	end
end
