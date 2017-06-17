module Controllers
	module AdminController
		## Provides requester with an html page to configure
        ## the instance of Youtube into AnyChannel
		def self.registered(app)
			app.post '/admin_ui' do
				@return_url = params[:return_url]
				puts params.inspect
				# File.read(File.join('public', 'admin.html.erb'))
				erb :'../public/admin.html'
				#redirect '/youtube_auth'
			end

			app.get '/admin_ui' do
				erb :'../public/admin.html'
			end
		end
	end
end
