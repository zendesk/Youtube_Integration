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

				puts metadata["credentials"]

				content = {}
				content = PullController.grab_all_videos_and_their_comments(service, content)

				# puts content
			end
		end

		## 
		# This method grabs all the videos from the authorized channel and will begin also grabbing all the comments from
		# those videos
		#
		def self.grab_all_videos_and_their_comments(service, content)
			response = service.list_searches('snippet', max_results: 50, for_mine: true, type: 'video')
				.to_json
			JSON.parse(response).fetch('items').each do |video|
				videoId = video.fetch('id').fetch('videoId')
				videoTitle = video.fetch('snippet').fetch('title')
				puts "===================#{videoTitle}================="
				comments = PullController.get_all_comments(service, videoId)
				if comments == false
					next
				end
				details = [videoTitle, comments]
				content[videoId] = details
			end

			while JSON.parse(response).include?('nextPageToken')
				nextPageToken = JSON.parse(response).fetch('nextPageToken') # Gets my page token for the next page
				response = service.list_searches('snippet', max_results: 50, for_mine: true, page_token: nextPageToken, type: 'video').to_json
				JSON.parse(response).fetch('items').each do |video|
					videoId = video.fetch('id').fetch('videoId')
					videoTitle = video.fetch('snippet').fetch('title')
					puts "===================#{videoTitle}================="
					comments = PullController.get_all_comments(service, videoId)
					if comments == false
						next
					end
					details = [videoTitle, comments]
					content[videoId] = details
				end
			end
			return content
		end

		## 
		# This method grabs all the comments from a particular videoId.
		# 
		def self.get_all_comments(service, videoId)
			begin
				response = service.list_comment_threads('snippet,replies', video_id: videoId).to_json
				comments = JSON.parse(response).fetch('items')
				while JSON.parse(response).include?('nextPageToken')
					nextPageToken = JSON.parse(response).fetch('nextPageToken') # Gets my page token for the next page
					response = service.list_comment_threads('snippet,replies', video_id: videoId, page_token: nextPageToken).to_json
					comments + JSON.parse(response).fetch('items')
				end
			rescue Exception => e # this catches the error when videos are made private thus disabling comments
				puts e
			end
		end

	end
end
