class CommentFetcher
  include InternalTimeoutHelper

  def initialize(video_page_token, client_opts, last_pull_time)
    @video_page_token = video_page_token
    @client_opts = client_opts
    @last_pull_time = last_pull_time
  end

  def fetch
    curr_time = video_page_token ? @last_pull_time : Time.now.to_datetime.rfc3339
    start_time = Time.now.to_i

		content = {}
		external_resources = []

		begin
			loop do
        content, video_page_token = grab_all_videos_and_their_comments(service, content, video_page_token)

        ## BEGIN GRABBING ALL COMMENTS AND REPLIES ##
        content.each do |videoId, comments|
          comments[1].each do |commentThread|
            topLevelComment = create_top_level_comment(commentThread)

            external_resources.push(topLevelComment) if topLevelComment['created_at'] > last_pull_time

            if commentThread['replies']
              commentThread['replies']['comments'].reverse_each do |comment|
                reply = create_reply(comment)

                external_resources.push(reply) if reply[:created_at] > last_pull_time
              end
            end
          end
        end
				break if video_page_token.nil?
			end
		rescue InternalTimeoutError => e
			puts "Timeout"
		ensure
			return {
				"external_resources": external_resources,
				"state": {
					"last_pull_time": curr_time,
					"video_page_token": video_page_token
				}.to_json
			}
		end
  end

  ##
  # This method grabs all the videos from the authorized channel and will begin also grabbing all the comments from
  # those videos
  #
  # Return format:
  # content = {
  # 	videoId1: [videoTitle, comments]
  # 	videoId2: [videoTitle, comments]
  # 	videoId3: [videoTitle, comments]
  # }
  #
  def self.grab_all_videos_and_their_comments(service, content, video_page_token, start_time)
    puts "=====#{video_page_token}====="
    response = nil

    execute_with_timeout(start_time) do
      response = if video_page_token.nil?
                   service.list_searches('snippet', max_results: 5, for_mine: true, type: 'video').to_json
                 else
                   service.list_searches('snippet', max_results: 5, for_mine: true, page_token: video_page_token, type: 'video').to_json
                 end
    end

    JSON.parse(response).fetch('items').each do |video|
      videoId = video.fetch('id').fetch('videoId')
      videoTitle = video.fetch('snippet').fetch('title')
      puts "===================#{videoTitle}================="

      comments = PullController.get_all_comments(service, videoId)

      next unless comments

      details = [videoTitle, comments]
      content[videoId] = details
    end

    return content, JSON.parse(response)['nextPageToken']
  end

  def get_all_comments(service, videoId, start_time)
    response = nil

    execute_with_timeout(start_time) do
      begin
        response = service.list_comment_threads('snippet,replies', video_id: videoId).to_json
      rescue Google::Apis::ClientError => e
        puts 'Error encountered when calling service.list_comment_threads. Rescuring so we can continue to get comments'
        puts e.inspect
      end
    end

    comments = JSON.parse(response).fetch('items')
    year_ago = Time.now.to_datetime - 365
    count = 0

    while JSON.parse(response).include?('nextPageToken')
      count += 1
      nextPageToken = JSON.parse(response).fetch('nextPageToken') # Gets my page token for the next page

      execute_with_timeout(start_time) do
        begin
          response = service.list_comment_threads('snippet,replies', video_id: videoId, page_token: nextPageToken).to_json
        rescue Google::Apis::ClientError => e
          puts 'Error encountered when calling service.list_comment_threads. Rescuring so we can continue to get comments'
          puts e.inspect
        end
      end

      # This breaks if the comment was published over a year ago and the video has over 300 existing comments already
      break if Time.parse(JSON.parse(response).fetch('items')[0]['snippet']['topLevelComment']['snippet']['publishedAt']).to_datetime.rfc3339 < year_ago.rfc3339 && count == 15
      comments += JSON.parse(response).fetch('items')
    end

    comments
  end

  class Comment
    attr_reader :video_id
    # commentThread => Hash
    def initialize(commentThread)
      @video_id = commentThread['snippet']['videoId']
    end

    def to_h
      {
        ...
        video_id: video_id
      }
    end
  end

  # TODO: This could be a Comment class
  # eg. Comment.new(commentThread)
  def create_top_level_comment(commentThread)
    video_id = commentThread.fetch('snippet').fetch('videoId')
    can_reply = commentThread.fetch('snippet').fetch('canReply')
    message = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('textOriginal')
    author_id = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('authorChannelId')
    author_display_name = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('authorDisplayName')
    author_display_image = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('authorProfileImageUrl')
    publish_date = commentThread.fetch('snippet').fetch('topLevelComment').fetch('snippet').fetch('publishedAt')
    publish_date = Time.parse(publish_date)
    publish_date = publish_date.to_datetime.rfc3339
    comment_id = commentThread.fetch('snippet').fetch('topLevelComment').fetch('id')

    {
      "external_id": "#{video_id}&lc=#{comment_id}",
      "message": "#{message}",
      "created_at": "#{publish_date}",
      "author": {
        "external_id": "#{author_id}",
        "name": "#{author_display_name}",
        "image_url": "#{author_display_image}"
      },
      "allow_channelback": can_reply,
      "display_info": [{
        "type": "youtube.com/integrations/youtube/display/comment/v1",
        "data": {
          videoId: video_id
        }
      }]
    }
  end

  # TODO: This could be a CommentReply class
  # eg. CommentReply.new(commentThread)
  def create_reply(comment)
    video_id = comment.fetch('snippet').fetch('videoId')
    message = comment.fetch('snippet').fetch('textOriginal')
    author_id = comment.fetch('snippet').fetch('authorChannelId')
    author_display_name = comment.fetch('snippet').fetch('authorDisplayName')
    author_display_image = comment.fetch('snippet').fetch('authorProfileImageUrl')
    publish_date = comment.fetch('snippet').fetch('publishedAt')
    publish_date = Time.parse(publish_date)
    publish_date = publish_date.to_datetime.rfc3339
    comment_id = comment.fetch('id')
    parent_id = comment.fetch('snippet').fetch('parentId')

    {
      "external_id": "#{video_id}&lc=#{comment_id}",
      "message": "#{message}",
      "created_at": "#{publish_date}",
      "parent_id": "#{video_id}&lc=#{parent_id}",
      "author": {
        "external_id": "#{author_id}",
        "name": "#{author_display_name}",
        "image_url": "#{author_display_image}"
      },
      "allow_channelback": true
    }
  end

  def client
    @client ||= begin
                  auth_client = Signet::OAuth2::Client.new(client_opts)
                  auth_client.fetch_access_token!
                  service = Google::Apis::YoutubeV3::YouTubeService.new
                  service.authorization = auth_client
                  service
                end
  end
end
