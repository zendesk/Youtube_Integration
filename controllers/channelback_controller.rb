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
				
				message = params[:message]									# Grabs the message
				channel_id = JSON.parse(metadata["channel_id"]) 			# Grabs the channel_id
				parent_id = params[:parent_id]
				
				snippet = Google::Apis::YoutubeV3::CommentSnippet.new(parent_id: parent_id, text_original: message)
				comment = Google::Apis::YoutubeV3::Comment.new(snippet: snippet)

				response = service.insert_comment('snippet', comment).to_json
				puts response
				external_id = JSON.parse(response).fetch('id')
				puts "ID: #{external_id}"
				{
				  "external_id": external_id,
				  "allow_channelback": true
				}.to_json
			end
		end

		def self.create_resource(properties)
		  	resource = {}
		  	properties.each do |prop, value|
		    	ref = resource
		    	prop_array = prop.to_s.split(".")
		    	for p in 0..(prop_array.size - 1)
		      		is_array = false
		      		key = prop_array[p]
		      		if key[-2,2] == "[]"
		        		key = key[0...-2]
		        		is_array = true
		      		end
			      	if p == (prop_array.size - 1)
			        	if is_array
			          		if value == ""
			            		ref[key.to_sym] = []
			          		else
			            		ref[key.to_sym] = value.split(",")
			          		end
			        	elsif value != ""
			          		ref[key.to_sym] = value
			        	end
		      		elsif ref.include?(key.to_sym)
		        		ref = ref[key.to_sym]
		      		else
		        		ref[key.to_sym] = {}
		        		ref = ref[key.to_sym]
		      		end
		    	end
		  	end
		  	return resource
		end
	end
end
