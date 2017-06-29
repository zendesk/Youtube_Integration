require 'date'
require 'json'

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
		#
		def self.registered(app)
			app.post '/pull' do
				puts 'I"M HERE'
				metadata = JSON.parse(params[:metadata])
				state = JSON.parse(params[:state])
				last_pull_time = state["last_pull_time"]
				last_pull_time = Time.parse(last_pull_time).to_time.iso8601
				curr_time = Time.now.to_datetime.rfc3339
				
				client_opts = JSON.parse(metadata["credentials"])
				auth_client = Signet::OAuth2::Client.new(client_opts)
				auth_client.fetch_access_token! 							# Refreshes my access token
				service = Google::Apis::YoutubeV3::YouTubeService.new
				service.authorization = auth_client

				content = {}
				video_page_token = state.include?("video_page_token") ? state["video_page_token"] : nil
				content, video_page_token = PullController.grab_all_videos_and_their_comments(service, content, video_page_token)

				external_resources = []

				## BEGIN GRABBING ALL COMMENTS AND REPLIES ##
				content.each do |videoId, comments|
					comments[1].each do |commentThread|
						topLevelComment = PullController.create_top_level_comment(commentThread)
						if topLevelComment[:created_at] > last_pull_time
							external_resources.push(topLevelComment)
						end
						if commentThread.include?('replies')
							commentThread.fetch('replies').fetch('comments').reverse_each do |comment|
								reply = PullController.create_reply(comment)
								if reply[:created_at] > last_pull_time
									external_resources.push(reply)	
								end
							end
						end
					end
				end
				return response = {
				"external_resources": external_resources,
						"state": {
							"last_pull_time": curr_time,
							"video_page_token": video_page_token
						}.to_json
				}.to_json
		end

		## 
		# This method grabs all the videos from the authorized channel and will begin also grabbing all the comments from
		# those videos
		#
		# Return format:
		# content = {
		# 	videoId1: [videoTitle, comments]
		# 	videoId2: [videoTitle, comments]
		# 	videoId3: [videoTitle, comments]
		# }
		#
		def self.grab_all_videos_and_their_comments(service, content, video_page_token)
			puts video_page_token
			response = video_page_token.nil? ? service.list_searches('snippet', max_results: 5, for_mine: true, type: 'video')
				.to_json : service.list_searches('snippet', max_results: 5, for_mine: true, page_token: video_page_token, type: 'video').to_json
			JSON.parse(response).fetch('items').each do |video|
				videoId = video.fetch('id').fetch('videoId')
				videoTitle = video.fetch('snippet').fetch('title')
				puts "===================#{videoTitle}================="
				comments = PullController.get_all_comments(service, videoId)
				if comments == false || comments == nil
					next
				end
				details = [videoTitle, comments]
				content[videoId] = details
			end

			video_page_token = JSON.parse(response).include?('nextPageToken') ? JSON.parse(response).fetch('nextPageToken') : nil

			######## THIS WILL GO THROUGH ALL VIDEOS FROM A CHANNEL IN 1 POLL ###########
			# while JSON.parse(response).include?('nextPageToken')
			# 	nextPageToken = JSON.parse(response).fetch('nextPageToken') # Gets my page token for the next page
			# 	response = service.list_searches('snippet', max_results: 50, for_mine: true, page_token: nextPageToken, type: 'video').to_json
			# 	JSON.parse(response).fetch('items').each do |video|
			# 		videoId = video.fetch('id').fetch('videoId')
			# 		videoTitle = video.fetch('snippet').fetch('title')
			# 		puts "=================== #{videoTitle} ================="
			# 		comments = PullController.get_all_comments(service, videoId)
			# 		if comments == false || comments.nil?
			# 			next
			# 		end
			# 		details = [videoTitle, comments]
			# 		content[videoId] = details
			# 	end
			# end

			return content, video_page_token
		end

		## 
		# This method grabs all the comments from a particular videoId.
		# 
		def self.get_all_comments(service, videoId)
			begin
				# response = service.list_comment_threads('snippet,replies', video_id: videoId).to_json
				response = service.list_comment_threads('snippet,replies', video_id: videoId).to_json
				comments = JSON.parse(response).fetch('items')
				year_ago = Time.now.to_datetime - 365
				count = 0
				while JSON.parse(response).include?('nextPageToken')
					count += 1
					nextPageToken = JSON.parse(response).fetch('nextPageToken') # Gets my page token for the next page
					response = service.list_comment_threads('snippet,replies', video_id: videoId, page_token: nextPageToken).to_json
					break if Time.parse(JSON.parse(response).fetch('items')[0].fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('publishedAt')).to_datetime.rfc3339 < year_ago.rfc3339 && count == 25
					comments = comments + JSON.parse(response).fetch('items')
				end
				puts comments.size
				return comments
			rescue Exception => e # this catches the error when videos are made private thus disabling comments
				puts e
			end
		end


		##
		# This method grabs all the information of the top level comment and creates a JSON object of it
		#
		def self.create_top_level_comment(commentThread)
			video_id = commentThread.fetch('snippet').fetch('videoId')
			can_reply = commentThread.fetch('snippet').fetch('canReply')
			message = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('textOriginal')
			author_id = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('authorChannelId')
			author_display_name = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('authorDisplayName')
			author_display_image = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('authorProfileImageUrl')
			publish_date = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('publishedAt')
			publish_date = Time.parse(publish_date)
			publish_date = publish_date.to_datetime.rfc3339
			comment_id = commentThread.fetch('snippet').fetch('topLevelComment').fetch('id')
			return response = {
					"external_id": "#{video_id}&lc=#{comment_id}",
					"message": "#{message}",
					"created_at": "#{publish_date}",
					"author": {
						"external_id": "#{author_id}",
						"name": "#{author_display_name}",
						"image_url": "#{author_display_image}"
					},
					"allow_channelback": can_reply,
					"display_info": [{
           			    "type": "youtube.com/integrations/youtube/display/comment/v1",
                		"data": {
                			videoId: video_id
                		}
              		}]
				}
			end
		end

		##
		# Grabs all the info of a reply and puts it into a JSON object.
		#
		def self.create_reply(comment)
			video_id = comment.fetch('snippet').fetch('videoId')
			message = comment.fetch('snippet').fetch('textOriginal')
			author_id = comment.fetch('snippet').fetch('authorChannelId')
			author_display_name = comment.fetch('snippet').fetch('authorDisplayName')
			author_display_image = comment.fetch('snippet').fetch('authorProfileImageUrl')
			publish_date = comment.fetch('snippet').fetch('publishedAt')
			publish_date = Time.parse(publish_date)
			publish_date = publish_date.to_datetime.rfc3339
			comment_id = comment.fetch('id')
			parent_id = comment.fetch('snippet').fetch('parentId')

			return response = {
						"external_id": "#{video_id}&lc=#{comment_id}",
						"message": "#{message}",
						"created_at": "#{publish_date}",
						"parent_id": "#{parent_id}",
						"author": {
							"external_id": "#{author_id}",
							"name": "#{author_display_name}",
							"image_url": "#{author_display_image}"
						},
						"allow_channelback": true
					}				
		end
	end
end
