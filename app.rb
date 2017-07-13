# frozen_string_literal: true

%w[controllers lib helpers].each do |path|
  Dir.glob(File.join(__dir__, "#{path}/**/*")).each { |file| require file }
end

class YoutubeIntegration < Sinatra::Base
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']

  helpers Sinatra::Helpers::InternalTimeoutHelper

  register Controllers::ManifestController
  register Controllers::PullController
  register Controllers::AdminController
  register Controllers::ChannelbackController
  register Controllers::YoutubeAuthController
  register Controllers::ClickthroughController
  register Controllers::EventCallbackController

  set :protection, except: %i[frame_options json_csrf] # turns off sameorigin in X-frame

  get '/' do
    File.read(File.join('public', 'index.html.erb'))
  end
end
