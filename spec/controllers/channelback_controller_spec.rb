# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/channelback_controller'

describe Controllers::ManifestController do
  describe 'POST /channelback' do
  	describe 'invalid credentials' do
	    before do
			  @metadata = {
			  	'credentials': {
			  		"authorization_uri": "https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=779541226128-btgh4e3kfgp6mjn41o3iiegd12pnq3ah.apps.googleusercontent.com&redirect_uri=https://0bba4895.ngrok.io/youtube_auth&response_type=code&scope=https://www.googleapis.com/auth/youtube.force-ssl",
			  	"token_credential_uri": "https://accounts.google.com/o/oauth2/token",
			  	"client_id": "779541226128-btgh4e3kfgp6mjn41o3iiegd12pnq3ah.apps.googleusercontent.com",
			  	"client_secret": "zzz",
			  	"scope": ["https://www.googleapis.com/auth/youtube.force-ssl"],
			  	"state": nil,
          "code": 'abc',
			  	"redirect_uri": "https://0bba4895.ngrok.io/youtube_auth",
			  	"username": nil,
			  	"password": nil,
			  	"issuer": nil,
			  	"audience": nil,
			  	"person": nil,
			  	"expiry": 60,
			  	"expires_at": 1499809779,
			  	"signing_key": nil,
			  	"refresh_token": nil,
			  	"access_token": "xD",
			  	"id_token": nil
			  	}.to_json
			  }.to_json
	    end

	    it 'should fail' do
        e = nil

	    	begin
					post '/channelback', metadata: @metadata, parent_id: 'parent_id', message: 'message'
				rescue StandardError => e
          expect(e.message).to match(/\AAuthorization\sfailed.*$/)
        ensure
          expect(e).to_not be_nil, 'Expected to make a channelback request that resulted in the client raising an error. No error was raised'
        end
	    end
	  end
	end
end
