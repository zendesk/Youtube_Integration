# frozen_string_literal: true

class CommentReply
  def initialize(comment)
    @video_id = comment['snippet']['videoId']
    @message = comment['snippet']['textOriginal']
    @author_id = comment['snippet']['authorChannelId']['value']
    @author_display_name = comment['snippet']['authorDisplayName']
    @author_display_image = comment['snippet']['authorProfileImageUrl']
    @publish_date = comment['snippet']['publishedAt']
    @publish_date = Time.parse(@publish_date)
    @publish_date = @publish_date.to_datetime.rfc3339
    @comment_id = comment['id']
    @parent_id = comment['snippet']['parentId']
  end

  def create_comment_reply
    {
      "external_id": "#{@video_id}&lc=#{@comment_id}",
      "message": @message,
      "created_at": @publish_date,
      "parent_id": "#{@video_id}&lc=#{@parent_id}",
      "author": {
        "external_id": @author_id,
        "name": @author_display_name,
        "image_url": @author_display_image
      },
      "allow_channelback": true
    }
  end
end
