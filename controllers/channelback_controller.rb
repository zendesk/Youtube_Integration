module Controllers
	module ChannelbackController
		## 
		# Takes the data provided by Zendesk and converts it into a comment using the Youtube API
        # 
		def self.registered(app)
			app.post '/channelback' do
				metadata = JSON.parse(params[:metadata])
				client_opts = JSON.parse(metadata["credentials"])
				auth_client = Signet::OAuth2::Client.new(client_opts)
				auth_client.fetch_access_token! 							# Refreshes my access token
				service = Google::Apis::YoutubeV3::YouTubeService.new
				service.authorization = auth_client							# Sets authentication
				
				message = params[:message]
				parent_id = params[:parent_id]
				
				# comment = ChannelbackController.create_comment(parent_id, message)
				# response = service.insert_comment('snippet', comment).to_json

				snippet = Google::Apis::YoutubeV3::CommentSnippet.new(parent_id: parent_id, text_original: message)
				comment = Google::Apis::YoutubeV3::Comment.new(snippet: snippet)
				response = service.insert_comment('snippet', comment).to_json

				comment_id = JSON.parse(response).fetch('id')
				video_id = JSON.parse(response).fetch('snippet').fetch('videoId')
				external_id = "#{video_id}&lc=#{comment_id}"
				
				{
				  "external_id": external_id,
				  "allow_channelback": true
				}.to_json
			end
		end

		##
		# Creates a Comment Resource using only the parent_id and message parameters.
		#
		def self.create_comment(parent_id, message)
			snippet = Google::Apis::YoutubeV3::CommentSnippet.new(parent_id: parent_id, text_original: message)
			return Google::Apis::YoutubeV3::Comment.new(snippet: snippet)
		end
	end
end
