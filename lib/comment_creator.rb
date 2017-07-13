# frozen_string_literal: true

class CommentCreator

  def initialize(client_opts, params)
    @client_opts = client_opts
    @message = params[:message]
    @info = params[:parent_id]
  end

  # Generates my comment. Begins by grabbing the parent_id and video_id from the params.
  def generate_comment
    video_id = @info.partition('&lc=').first
    @parent_id = @info.partition('&lc=').last.partition('.').first
    
    comment_snippet = create_comment_snippet
    response = client.insert_comment('snippet', comment_snippet).to_json

    comment_id = JSON.parse(response).fetch('id')
    external_id = "#{video_id}&lc=#{comment_id}"

    {
      "external_id": external_id,
      "allow_channelback": true
    }.to_json
  end

  # Creates my comment snippet object to give to Youtube API
  def create_comment_snippet
      snippet = Google::Apis::YoutubeV3::CommentSnippet.new(parent_id: @parent_id, text_original: @message)
      Google::Apis::YoutubeV3::Comment.new(snippet: snippet)
    end

  def client
    @client ||= begin
                  auth_client = Signet::OAuth2::Client.new(@client_opts)
                  auth_client.fetch_access_token!
                  service = Google::Apis::YoutubeV3::YouTubeService.new
                  service.authorization = auth_client
                  service
                end
  end
end
