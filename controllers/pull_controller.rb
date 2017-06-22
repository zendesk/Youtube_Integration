module Controllers
	module PullController
		## 
		# This is the primary polling request received. We parse the metadata auth credentials
		# and make a request to the Youtube API. The response is formatted and returned to AnyChannel
		# in the required format. 
		#
		# EXAMPLE FORMAT:
		# response = {
		# 			"external_resources":[
		# 				{
		# 					"external_id": "1126",
		# 					"message": "Is my Channel ID here?",
		# 					"created_at": "2017-06-13T14:34:09Z",
		# 					"author": {
		# 						"external_id": "author_external_id",
		# 						"name": "author_name"
		# 					},
		# 					"allow_channelback": true
		# 				}],
		# 			"state": "some state time",
		# 		}.to_json

		def self.registered(app)
			app.post '/pull' do
				metadata = JSON.parse(params[:metadata])
				state = params[:state]

				client_opts = JSON.parse(metadata["credentials"])
				auth_client = Signet::OAuth2::Client.new(client_opts)
				auth_client.fetch_access_token! 							# Refreshes my access token
				service = Google::Apis::YoutubeV3::YouTubeService.new
				service.authorization = auth_client

				puts auth_client.to_json

				videoIds = []
				puts params.inspect
				puts metadata["credentials"]
				response = service.list_searches('snippet', max_results: 50, for_mine: true, type: 'video')
				.to_json
				JSON.parse(response).fetch('items').each do |video|
					videoIds.push(video.fetch('id').fetch('videoId'))
				end
				
				# nextPageToken = JSON.parse(response).fetch('nextPageToken') # Gets my page token for the next page
				# while nextPageToken != nil # Loops through all of my pages until there are no more pages
				# 	response = service.list_searches('snippet', max_results: 50, for_mine: true, pageToken: nextPageToken, type: 'video').to_json
				# 	nextPageToken = JSON.parse(response).fetch('nextPageToken') # Gets my page token for the next page
				# 	JSON.parse(response).fetch('items').each do |video|
				# 		videoIds.push(video.fetch('id').fetch('videoId'))
				# 	end
				# end
			end
		end
	end
end
