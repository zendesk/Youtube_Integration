# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/pull_controller'

describe Controllers::PullController do
  describe 'POST /pull' do
  	describe 'success' do
     before do
       @metadata = metadata_with_valid_auth_credentials
       @state = state
       VCR.use_cassette("pull_success", :match_requests_on => [:uri, :body, :method]) do
            post '/pull', metadata: @metadata, state: @state
        end
     end

      it 'returns a 200 status' do
      	expect(last_response.status).to eql(200)
	  	end

    	it 'returns a json body in a valid Zendesk format' do
	     	response = last_response.body
	     	validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.pull_payload, response)
	      expect(validation_errors).to be_empty
	    end
	  end

	  describe 'fail' do
	  	before do
	  		@metadata = metadata_with_invalid_auth_credentials
	  		@state = state
	  		VCR.use_cassette("pull_fail", :match_requests_on => [:uri, :body, :method]) do
            post '/pull', metadata: @metadata, state: @state
        end
	  	end

	  	it 'should contain empty external resources' do
	  		expect(JSON.parse(last_response.body)['external_resources']).to eql([])
	  	end
	  end
  end
end
