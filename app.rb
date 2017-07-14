# frozen_string_literal: true

%w[controllers lib helpers].each do |path|
  Dir.glob(File.join(__dir__, "#{path}/**/*")).each { |file| require file }
end

class YoutubeIntegration < Sinatra::Base
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :protection, except: %i[frame_options json_csrf] # turns off sameorigin in X-frame

  error Signet::AuthorizationError do
    # https://developer.zendesk.com/apps/docs/channels-framework/pull_endpoint#recognized-error-responses
    # it also indicates that Zendesk to retry the request.
    [401, {}, 'AuthError']
  end

  error StandardError do
    [500, {}, 'An error occurred']
  end

  helpers Sinatra::Helpers::InternalTimeoutHelper

  register Controllers::ManifestController
  register Controllers::PullController
  register Controllers::AdminController
  register Controllers::ChannelbackController
  register Controllers::YoutubeAuthController
  register Controllers::ClickthroughController
  register Controllers::EventCallbackController


  get '/' do
    File.read(File.join('public', 'index.html.erb'))
  end
end
