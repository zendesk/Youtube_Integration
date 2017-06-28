module Controllers
	module ClickthroughController
		## 
		# Fetches the Youtube video that corresponds to a comment and highlights that comment.
        # 
		def self.registered(app)
			app.get '/clickthrough' do
				external_id = params[:external_id]
				redirect "https://www.youtube.com/watch?v=#{external_id}"
			end
		end
	end
end
