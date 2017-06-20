require 'spec_helper'
require_relative '../../controllers/channelback_controller'

describe Controllers::ManifestController do
	before do
		post '/channelback'
	end

	it 'list should have 0 errors when manifest schema conforms' do
		channelback = last_response.body
		validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.channelback_payload, channelback)
	 	expect(validation_errors).to be_empty
	end

	it 'returns true when the get status is 200' do
		expect(last_response.status).to be 200
	end
end
