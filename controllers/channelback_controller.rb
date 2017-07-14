# frozen_string_literal: true

module Controllers
  module ChannelbackController
    ##
    # Takes the data provided by Zendesk and converts it into a comment using the Youtube API
    #
    def self.registered(app)
      app.post '/channelback' do
        begin
          metadata = JSON.parse(params[:metadata])
          comment_creator = CommentCreator.new(JSON.parse(metadata['credentials']), params)

          [200, { 'ContentType' => 'application/json' }, comment_creator.generate_comment]
        rescue Signet::AuthorizationError => e
          # https://developer.zendesk.com/apps/docs/channels-framework/pull_endpoint#recognized-error-responses
          # it also indicates that Zendesk to retry the request.
          [401, {}, 'AuthError']
        rescue => e

          [500, {}, 'An error occurred attempting to POST a reply to Youtube.']
        end
      end
    end
  end
end
