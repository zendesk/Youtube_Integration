require 'date'
require 'logger'
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
				metadata = JSON.parse(params[:metadata])
				state    = JSON.parse(params[:state])

        comment_fetcher = CommentFetcher.new(
          state['video_page_token'],
          JSON.parse(metadata["credentials"]),
          Time.parse(state['last_pull_time']).to_time.iso8601
        )

        [200, {}, comment_fetcher.fetch.to_json]
      end
		end
	end
end
