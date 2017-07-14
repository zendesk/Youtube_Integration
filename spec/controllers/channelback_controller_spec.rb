# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/channelback_controller'

describe Controllers::ChannelbackController do
  describe 'POST /channelback' do
    describe 'channelback success' do
     before do
       @metadata = metadata_with_valid_auth_credentials
       VCR.use_cassette("channelback_success", :match_requests_on => [:uri, :body, :method]) do
            post '/channelback', metadata: @metadata, parent_id: 'kDyX_H9UG9c&lc=z13rsx1pbzjhvjfxq04cjzehttrnif3qavw0k', message: 'message'
        end
     end

      it 'returns a 200 status' do
      	expect(last_response.status).to eql(200)
	  	end

      it 'sets the response header: ContentType: application/json' do
      	expect(last_response.headers["ContentType"]).to eql('application/json')
    	end

    	it 'returns a json body in a valid Zendesk format' do
	     	manifest = last_response.body
	     	validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.channelback_payload, manifest)
	      expect(validation_errors).to be_empty
	    end
   	end

    describe 'channelback_fail' do
      before do
        @metadata = metadata_with_invalid_auth_credentials
      end

      describe 'POST to youtube with credentials that do not authorize' do
        it 'returns a 401 status code' do
          VCR.use_cassette("channelback_fail") do
            post '/channelback', metadata: @metadata, parent_id: 'parent_id', message: 'message'

            expect(last_response.status).to eql(401)
          end
        end

        it 'returns a text body explaining the error' do
          VCR.use_cassette("channelback_401") do
            post '/channelback', metadata: @metadata, parent_id: 'parent_id', message: 'message'

            expect(last_response.body).to eql('AuthError')
          end
        end
      end

      describe 'POSTing to youtube that results in a 500' do
        it 'returns a 500 status code' do
          VCR.use_cassette("channelback_valid_auth") do
            post '/channelback', metadata: metadata_with_valid_auth_credentials, parent_id: 'parent_id', message: 'message'

            expect(last_response.status).to eq(500)
          end
        end
      end
    end
  end
end
