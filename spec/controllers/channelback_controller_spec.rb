# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/channelback_controller'

describe Controllers::ManifestController do
  describe 'POST /channelback' do
    #describe 'valid credentials' do
    #  before do
    #    WebMock.stub_request(:post, "https://accounts.google.com/o/oauth2/token")
    #      .to_return(
    #        body: MultiJson.dump(
    #          'access_token' => 'hunter1', 'token_type' => 'Bearer', 'expires_in' => 3600
    #        ),
    #        status: 200,
    #        headers: { 'ContentType' => 'application/json' }
    #      )
    #  end

    #  it 'returns a 200 status' do
    #    post '/channelback', metadata: @metadata, parent_id: 'parent_id', message: 'message'

    #    expect(last_response.status).to eql(200)
    #  end

    #  it 'sets the response header: ContentType: application/json' do
    #  end

    #  it 'returns a json body in a valid Zendesk format' do
    #  end

    #  it 'returns the correct values' do
    #  end
    #end

    describe 'invalid credentials' do
      before do
        @metadata = metadata_with_invalid_auth_credentials
      end

      describe 'POST to youtube with credentials that do not authorize' do
        it 'returns a 401 status code' do
          VCR.use_cassette("channelback_401") do
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
            post '/channelback', metadata: metadata_with_valid_credentials, parent_id: 'parent_id', message: 'message'
            # TODO: This should be a real test
            last_response.status.inspect
          end
        end
      end
    end
  end
end
