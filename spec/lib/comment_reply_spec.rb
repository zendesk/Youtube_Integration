# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/comment'

describe CommentReply do
  before do
    @reply = {
      "kind": "youtube#comment",
      "etag": 'etag',
      "id": 'string',
      "snippet": {
        "authorDisplayName": 'string',
        "authorProfileImageUrl": 'string',
        "authorChannelUrl": 'string',
        "authorChannelId": {
          'value': 'heh'
          },
        "channelId": 'string',
        "videoId": 'string',
        "textDisplay": 'string',
        "textOriginal": 'messageeeee reply',
        "parentId": 'string',
        "canRate": true,
        "viewerRating": 'string',
        "likeCount": 12,
        "moderationStatus": 'string',
        "publishedAt": Time.now,
        "updatedAt": Time.now
      }
    }.to_json

    raw_reply = CommentReply.new(JSON.parse(@reply))
    @reply = raw_reply.create_comment_reply
    @reply = @reply.to_json
  end

  it 'should create a reply' do
    expect(JSON.parse(@reply)['external_id']).to be_truthy
    expect(JSON.parse(@reply)['message']).to be_truthy 
    expect(JSON.parse(@reply)['created_at']).to be_truthy 
    expect(JSON.parse(@reply)['author']).to be_truthy 
    expect(JSON.parse(@reply)['author']['external_id']).to be_truthy 
    expect(JSON.parse(@reply)['author']['name']).to be_truthy 
    expect(JSON.parse(@reply)['author']['image_url']).to be_truthy 
    expect(JSON.parse(@reply)['allow_channelback']).to be_truthy 
    expect(JSON.parse(@reply)['parent_id']).to be_truthy 
  end

  it 'should be in the correct external_resources format' do
    validation_errors = JSON::Validator.fully_validate(AnyChannelJSONSchemas.external_resource, JSON.parse(@reply))
    expect(validation_errors).to be_empty
  end
end
