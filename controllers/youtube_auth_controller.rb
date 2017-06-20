require 'google/api_client/client_secrets'
require 'google/apis/youtube_v3'
require 'uri'
require 'net/http'

module Controllers
	module YoutubeAuthController
		def self.registered(app)
			app.get '/auth_display' do
				unless session.has_key?(:credentials)
			    	redirect to('/youtube_auth')
			  	end
			  	
				metadata = {
					"channel_name": session[:channel_name],
					"credentials": session[:credentials]
				}
				state = {
					"last_msg": session[:timestamp]
				}

				uri = URI(session[:return_url])
				https = Net::HTTP.new(uri.host, uri.port)
				request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
				request.body = {
					'metadata': metadata,
					'state': state,
					'name': session[:channel_name],
					'return_url': session[:return_url],
					'subdomain': session[:subdomain],
					'locale': session[:locale]
				}.to_json
				puts request.body
				response = https.request(request)
				
			end

			app.get '/youtube_auth' do
				client_secrets = Google::APIClient::ClientSecrets.load
				auth_client = client_secrets.to_authorization
				auth_client.update!(
				  	:scope => 'https://www.googleapis.com/auth/youtube.force-ssl',
				  	:redirect_uri => "https://0bba4895.ngrok.io/youtube_auth"
				)
				if request['code'] == nil
					session.delete(:channel_name)
			  		session.delete(:credentials); session.delete(:return_url); session.delete(:channel_id)
			  		session.delete(:timestamp); session.delete(:subdomain); session.delete(:locale)
					session[:channel_name] = params['channel_name']
					session[:channel_id] = params['channel_id']
					session[:return_url] = params['return_url']
					session[:timestamp] = params['timestamp']
					session[:locale] = params['locale']
					session[:subdomain] = params['subdomain']
					auth_uri = auth_client.authorization_uri.to_s
					redirect auth_uri
				else
					auth_client.code = request['code']
					auth_client.fetch_access_token!
					auth_client.client_secret = nil				# hide my client_secret
    				session[:credentials] = auth_client.to_json # set my session 
    				redirect '/auth_display'
    			end
			end
		end
	end
end
