module Controllers
	module AdminController
		## Provides requester with an html page to configure
        ## the instance of Youtube into AnyChannel
		def self.registered(app)
			app.post '/admin_ui' do
				@return_url = params[:return_url]
				@subdomain = params[:subdomain]
				@locale = params[:locale]
				session[:return_url] = @return_url # stores my return_url
				erb :'../public/admin.html'
			end

			app.get '/admin_ui' do
				erb :'../public/admin.html'
			end
		end
	end
end
