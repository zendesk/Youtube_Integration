# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/admin_controller'

describe Controllers::AdminController do
  before do
    get '/admin'
  end

  it 'returns true when the get status is 200' do
    expect(last_response.status).to be 200
  end
end
