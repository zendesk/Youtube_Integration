# frozen_string_literal: true

module Controllers
  module ManifestController
    def self.registered(app)
      app.get '/manifest' do
        content_type :json
        File.read('manifest.json.erb')
      end
    end
  end
end
