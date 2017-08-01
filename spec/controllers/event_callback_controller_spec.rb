# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/event_callback_controller'

describe Controllers::EventCallbackController do
  before do
    post '/event_callback'
  end

  # it 'list should have 0 errors when manifest schema conforms' do
  # 	callback = last_response.body
  # 	validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.channelback_payload, callback)
  #  	expect(validation_errors).to be_empty
  # end

  # it 'returns true when the get status is 200' do
  #   expect(last_response.status).to be 200
  # end
end
