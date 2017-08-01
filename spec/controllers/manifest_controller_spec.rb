# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/manifest_controller'

describe Controllers::ManifestController do
  describe 'GET /manifest.json' do
    before { get '/manifest'}

    it 'list should have 0 errors when manifest schema conforms' do
      manifest = last_response.body
      validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.manifest, manifest)
      expect(validation_errors).to be_empty
    end

    it 'is successful' do
      expect(last_response.status).to eq(200)
    end
  end

  describe 'an invalid path' do
    before { get '/invalid.json' }

    it 'returns a not found response' do
      expect(last_response.status).to eq(404)
    end
  end
end
