# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/admin_controller'

describe Controllers::AdminController do
	describe 'GET /admin_ui' do
	  before { post '/admin_ui' }

	  it 'is successful' do
	    expect(last_response.status).to be 200
	  end
	end

	describe 'invalid path' do
		before { post '/foo_ui' }

		it 'returns a not found path' do
			expect(last_response.status).to eq(404)
		end
	end
end
