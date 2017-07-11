# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/pull_controller'

describe Controllers::ClickthroughController do
  describe 'GET /clickthrough' do
    before { get '/clickthrough?external_id=q-fKlOIDl2E' }
    
    it 'is successful' do
    	expect(last_response.status).to eq(302) # Expects redirect code 302
    end
  end
end
