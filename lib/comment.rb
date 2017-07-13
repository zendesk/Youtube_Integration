# frozen_string_literal: true

class Comment
  def initialize(commentThread)
    @video_id = commentThread['snippet']['videoId']
    @can_reply = commentThread['snippet']['canReply']
    @message = commentThread['snippet']['topLevelComment']['snippet']['textOriginal']
    @author_id = commentThread['snippet']['topLevelComment']['snippet']['authorChannelId']['value']
    @author_display_name = commentThread['snippet']['topLevelComment']['snippet']['authorDisplayName']
    @author_display_image = commentThread['snippet']['topLevelComment']['snippet']['authorProfileImageUrl']
    @publish_date = commentThread['snippet']['topLevelComment']['snippet']['publishedAt']
    @publish_date = Time.parse(@publish_date)
    @publish_date = @publish_date.to_datetime.rfc3339
    @comment_id = commentThread['snippet']['topLevelComment']['id']
  end

  def create_top_level_comment
    {
      "external_id": "#{@video_id}&lc=#{@comment_id}",
      "message": @message,
      "created_at": @publish_date,
      "author": {
        "external_id": @author_id,
        "name": @author_display_name,
        "image_url": @author_display_image
      },
      "allow_channelback": @can_reply,
      "display_info": [{
        "type": 'youtube.com/integrations/youtube/display/comment/v1',
        "data": {
          'videoId': @video_id
        }
      }]
    }
  end
end
