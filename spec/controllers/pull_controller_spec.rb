# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/pull_controller'

describe Controllers::PullController do
  before do
    post '/pull'
  end

  it 'returns true when the get status is 200' do
    expect(last_response.status).to be 200
  end

  it 'list should have 0 errors when manifest schema conforms' do
    response = last_response.body
    validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.pull_payload, response)
    expect(validation_errors).to be_empty
  end
end
