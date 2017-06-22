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

				puts metadata["credentials"]
				# credentials = JSON.parse(metadata["credentials"])
				# puts "CREDENTIALS: #{credentials}"
				# # puts "GETTING ACCESS TOKEN #{credentials["access_token"]}"
				client_opts = JSON.parse(metadata["credentials"])
				auth_client = Signet::OAuth2::Client.new(client_opts)
				service = Google::Apis::YoutubeV3::YouTubeService.new
				service.authorization = auth_client
				response = service.list_searches('snippet', max_results: 50, for_mine: true, type: 'video')
				puts response.to_json
				# response = {
				# 	"external_resources":[
				# 		{
				# 			"external_id": "1127",
				# 			"message": "Is my Channel ID here?",
				# 			"created_at": "2017-06-13T14:34:09Z",
				# 			"author": {
				# 				"external_id": "author_external_id",
				# 				"name": "author_name"
				# 			},
				# 			"allow_channelback": true
				# 		}],
				# 	"state": "some state time",
				# }.to_json
			end
		end
	end
end
