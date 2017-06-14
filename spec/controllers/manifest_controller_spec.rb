require 'spec_helper'
require_relative '../../controllers/manifest_controller'

describe Controllers::ManifestController do
	before do
		get '/manifest'
	end

	it 'list should have 0 errors when manifest schema conforms' do
		manifest = last_response.body
		validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.manifest, manifest)
	 	expect(validation_errors).to be_empty
	end

	it 'returns true when the get status is 200' do
		expect(last_response.status).to be 200
	end
end
