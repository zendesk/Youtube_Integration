module Controllers
	module PullController
		## This is the primary polling request received. We parse the metadata auth credentials
		## and make a request to the Youtube API. The response
		## is formatted and returned to AnyChannel in the required
		## format. 

		def self.registered(app)
			app.post '/pull' do
				response = {
					"external_resources":[
						{
							"external_id": "1112",
							"message": "Hey this is a comment!",
							"created_at": "2017-06-13T14:34:09Z",
							"author": {
								"external_id": "author_external_id",
								"name": "author_name"
							},
							"allow_channelback": true
						}],
					"state": "some state time"
				}.to_json
			end
		end
	end
end
