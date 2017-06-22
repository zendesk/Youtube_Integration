%w(controllers).each do |path|
  Dir.glob(File.join(__dir__, "#{path}/**/*")).each { |file| require file }
end

class YoutubeIntegration < Sinatra::Base
	enable :sessions
	set :session_secret, 'setme'

	register Controllers::ManifestController
	register Controllers::PullController
	register Controllers::AdminController
	register Controllers::ChannelbackController
	register Controllers::YoutubeAuthController

	set :protection, except: [:frame_options, :json_csrf] # turns off sameorigin in X-frame

	get '/' do
		File.read(File.join('public', 'index.html'))
	end
end
