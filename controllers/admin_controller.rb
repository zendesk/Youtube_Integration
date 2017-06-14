module Controllers
	module AdminController
		## Provides requester with an html page to configure
        ## the instance of Youtube into AnyChannel
		def self.registered(app)
			app.post '/admin_ui' do
				# "admin_ui page"
				erb :admin
			end
		end
	end
end
