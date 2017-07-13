# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/comment'

describe Comment do
  before do
    @comment_thread = {
      "kind": "youtube#commentThread",
      "etag": 'xD',
      "id": 'string',
      "snippet": {
        "channelId": 'channelId',
        "videoId": 'coolvideo123',
        "topLevelComment": {
          "kind": "youtube#comment",
          "etag": 'etag',
          "id": 'string',
          "snippet": {
            "authorDisplayName": 'string',
            "authorProfileImageUrl": 'string',
            "authorChannelUrl": 'string',
            "authorChannelId": {
                "value": 'swag'
            },
            "channelId": 'string',
            "videoId": 'string',
            "textDisplay": 'string',
            "textOriginal": 'string',
            "parentId": 'string',
            "canRate": true,
            "viewerRating": 'string',
            "likeCount": 3,
            "moderationStatus": 'string',
            "publishedAt": Time.now,
            "updatedAt": Time.now
          }
        },
        "canReply": true,
        "totalReplyCount": 1,
        "isPublic": true
      },
      "replies": {
        "comments": [
          {
            "kind": "youtube#comment",
            "etag": 'etag',
            "id": 'string',
            "snippet": {
              "authorDisplayName": 'string',
              "authorProfileImageUrl": 'string',
              "authorChannelUrl": 'string',
              "authorChannelId": {
                "value": 'string'
              },
              "channelId": 'string',
              "videoId": 'string',
              "textDisplay": 'string',
              "textOriginal": 'messageeeee',
              "parentId": 'string',
              "canRate": true,
              "viewerRating": 'string',
              "likeCount": 12,
              "moderationStatus": 'string',
              "publishedAt": Time.now,
              "updatedAt": Time.now
            }
          }
        ]
      }
    }.to_json

    raw_top_level_comment = Comment.new(JSON.parse(@comment_thread))
    @top_level_comment = raw_top_level_comment.create_top_level_comment
    @top_level_comment = @top_level_comment.to_json
  end

  it 'should create a top level comment' do
    expect(JSON.parse(@top_level_comment)['external_id']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['message']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['created_at']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['author']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['author']['external_id']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['author']['name']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['author']['image_url']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['allow_channelback']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['display_info']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['display_info'][0]['type']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['display_info'][0]['data']).to be_truthy 
    expect(JSON.parse(@top_level_comment)['display_info'][0]['data']['videoId']).to be_truthy 
  end

  it 'should be in the correct external_resources format' do
    validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.external_resource, JSON.parse(@top_level_comment))
    expect(validation_errors).to be_empty
  end
end
