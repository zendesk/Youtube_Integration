# frozen_string_literal: true

require_relative '../helpers/internal_timeout_helper'

class CommentFetcher
  include Sinatra::Helpers::InternalTimeoutHelper

  def initialize(video_page_token, client_opts, last_pull_time)
    @initial_video_page_token = video_page_token
    @client_opts = client_opts
    @last_pull_time = last_pull_time
  end

  def fetch
    curr_time = @video_page_token ? @last_pull_time : (Time.now.to_datetime - 1).rfc3339
    start_time = Time.now.to_i
    content = {}; external_resources = []
    begin
      video_page_token = @initial_video_page_token
      loop do
        content, video_page_token = grab_all_videos_and_their_comments(content, video_page_token, start_time)
        ## BEGIN GRABBING ALL COMMENTS AND REPLIES ##
        content.each do |_video_id, comments|
          comments[1].each do |comment_thread|
            raw_comment = Comment.new(comment_thread)
            top_level_comment = raw_comment.create_top_level_comment
            external_resources.push(top_level_comment) if top_level_comment[:created_at] > @last_pull_time
            next unless comment_thread['replies']
            comment_thread['replies']['comments'].reverse_each do |comment|
              raw_reply = CommentReply.new(comment)
              reply = raw_reply.create_comment_reply
              external_resources.push(reply) if reply[:created_at] > @last_pull_time
            end
          end
        end
        break if video_page_token.nil?
      end
    rescue InternalTimeoutError
      puts 'Timeout'
    ensure
      puts external_resources
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
  def grab_all_videos_and_their_comments(content, video_page_token, start_time)
    puts "=================== Video Page Token: #{video_page_token} ==================="
    response = nil
    execute_with_timeout(start_time) do
      response = if video_page_token.nil?
                   client.list_searches('snippet', max_results: 5, for_mine: true, type: 'video').to_json
                 else
                   client.list_searches('snippet', max_results: 5, for_mine: true, page_token: video_page_token, type: 'video').to_json
                 end
    end
    JSON.parse(response).fetch('items').each do |video|
      video_id = video.fetch('id').fetch('videoId')
      video_title = video.fetch('snippet').fetch('title')
      puts "=================== Grabbing: #{video_title} ==================="
      comments = get_all_comments(video_id, start_time)
      next unless comments
      details = [video_title, comments]
      content[video_id] = details
    end
    [content, JSON.parse(response)['nextPageToken']]
  end

  # Grabs all the comments on a video. If the video contains over 200 comments, then it will only grab the most recent 200 comments
  def get_all_comments(video_id, start_time)
    response = nil; next_page_token = nil; comments = []; year_ago = Time.now.to_datetime - 365; count = 0
    loop do
      execute_with_timeout(start_time) do
        begin
          response = if next_page_token.nil?
                       client.list_comment_threads('snippet,replies', video_id: video_id).to_json
                     else
                       client.list_comment_threads('snippet,replies', video_id: video_id, page_token: next_page_token).to_json
                     end
          comments += JSON.parse(response).fetch('items')
          count += 1
          return comments unless JSON.parse(response).include?('nextPageToken')
          next_page_token = JSON.parse(response).fetch('nextPageToken')
        rescue Google::Apis::ClientError => e
          puts 'Error encountered when calling client.list_comment_threads. Rescuing so we can continue to get comments'
          puts e.inspect
          return comments
        end
      end
      break if grab_publish_date(response) < year_ago.rfc3339 && count == 10 # 200 comments max
    end
    comments
  end

  def grab_publish_date(response)
    Time.parse(JSON.parse(response).fetch('items')[0]['snippet']['topLevelComment']['snippet']['publishedAt']).to_datetime.rfc3339
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
