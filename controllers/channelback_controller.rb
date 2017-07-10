# frozen_string_literal: true

module Controllers
  module ChannelbackController
    ##
    # Takes the data provided by Zendesk and converts it into a comment using the Youtube API
    #
    def self.registered(app)
      app.post '/channelback' do
        metadata = JSON.parse(params[:metadata])
        comment_creator = CommentCreator.new(JSON.parse(metadata['credentials']), params)
        comment_creator.generate_comment
      end
    end
  end
end
