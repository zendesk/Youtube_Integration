# frozen_string_literal: true

module Controllers
  module EventCallbackController
    def self.registered(app)
      app.post '/event_callback' do
        # returns nothing
        'This is the event_callback page which I can use to collect data in the future.'
      end
    end
  end
end
