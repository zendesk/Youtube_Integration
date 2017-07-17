# frozen_string_literal: true

%w[controllers lib helpers].each do |path|
  Dir.glob(File.join(__dir__, "#{path}/**/*")).each { |file| require file }
end

if ENV['AIRBRAKE_ID']
  Airbrake.configure do |c|
    c.project_id = ENV['AIRBRAKE_ID']
    c.project_key = ENV['AIRBRAKE_KEY']

    # Display debug output.
    c.logger.level = Logger::DEBUG
  end
end

class YoutubeIntegration < Sinatra::Base
  use Airbrake::Rack::Middleware
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :protection, except: %i[frame_options json_csrf] # turns off sameorigin in X-frame

  error Signet::AuthorizationError do
    # https://developer.zendesk.com/apps/docs/channels-framework/pull_endpoint#recognized-error-responses
    # it also indicates to Zendesk to retry the request.
    [401, {}, 'AuthError']
  end

  error 500 do
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
