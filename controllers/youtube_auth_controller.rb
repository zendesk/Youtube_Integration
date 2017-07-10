# frozen_string_literal: true

require 'google/api_client/client_secrets'
require 'google/apis/youtube_v3'
require 'uri'
require 'net/http'

module Controllers
  module YoutubeAuthController
    def self.registered(app)
      ##
      # /auth_display checks if the Google Authentication was completed by first checking for credentials inside the
      # session. If the session doesn't exist, redirect to /auth_error and display an error.
      #
      # Creates metadata, state, and name information from session cookies that was previously stored in /youtube_auth
      # Submits a POST request via hidden inputs inside an HTML form inside /auto_submit.html.erb. The POST request
      # includes the metadata, state, and name to store in Zendesk.
      app.get '/auth_display' do
        if !session.key?(:credentials)
          redirect '/auth_error'
        else
          @metadata = {
            "channel_name": session[:channel_name],
            "credentials": session[:credentials]
          }.to_json
          @state = {
            "last_pull_time": session[:timestamp]
          }.to_json
          @name = session[:channel_name]
          @return_url = session[:return_url]
          erb :'../public/auto_submit.html'
        end
      end

      ##
      # /youtube_auth is where the Google OAuth is initiated. The token is saved fetched and saved into the session as a # cookie. All previous cookies relating to the metadata is deleted before the authentication process begins.
      app.get '/youtube_auth' do
        client_secrets = Google::APIClient::ClientSecrets.new(JSON.parse(ENV['CLIENT_SECRET']))
        auth_client = client_secrets.to_authorization
        auth_client.update!(
          scope: 'https://www.googleapis.com/auth/youtube.force-ssl',
          redirect_uri: ENV['AUTH_REDIRECT_URL']
        )
        if request['code'].nil?
          session.delete(:channel_name)
          session.delete(:credentials); session.delete(:return_url)
          session.delete(:timestamp); session.delete(:subdomain); session.delete(:locale)
          session[:channel_name] = params['channel_name']
          session[:return_url] = params['return_url']
          session[:timestamp] = params['timestamp']
          session[:locale] = params['locale']
          session[:subdomain] = params['subdomain']
          auth_uri = auth_client.authorization_uri.to_s
          redirect auth_uri
        else
          auth_client.code = request['code']
          puts auth_client.to_json

          auth_client.fetch_access_token!
          puts auth_client.to_json
          # auth_client.client_secret = nil
          session[:credentials] = auth_client.to_json
          redirect '/oauth_done'
          end
      end

      ##
      # OAuth is completed. Window will be automatically be closed.
      #
      app.get '/oauth_done' do
        erb :'../public/oauth_completed.html'
      end

      ##
      # There was a problem with the Google OAuth process. /auth_error.html.erb indicates to users that something
      # went wrong
      #
      app.get '/auth_error' do
        erb :'../public/auth_error.html'
      end
    end
  end
end
