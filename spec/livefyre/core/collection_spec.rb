# coding: utf-8

require 'livefyre/spec_helper'
require 'livefyre'
require 'jwt'

describe Livefyre::Collection do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end

  it 'should raise ArgumentError if url is not a valid url for collection' do
    expect{ @site.build_livecomments_collection('test', 'test', 'blah.com/') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if title is more than 255 characters for collection' do
    expect{ @site.build_livecomments_collection('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', 'test', 'http://test.com', 'test') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if not a valid type is passed in when building a collection' do
    expect{ @site.build_collection('bad_type', '', '', 'http://livefyre.com') }.to raise_error(ArgumentError)
  end

  it 'should check type and assign them to the correct field in the collection meta token' do
    @token = @site.build_reviews_collection('title', 'article_id', 'http://livefyre.com').build_collection_meta_token
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('reviews')

    @token = @site.build_liveblog_collection('title', 'article_id', 'http://livefyre.com').build_collection_meta_token
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('liveblog')
  end

  it 'should return a collection meta token' do
    expect{ @site.build_livecomments_collection('title', 'article_id', 'https://www.url.com').build_collection_meta_token }.to be_true
  end

  it 'should return a valid checksum' do
    collection = @site.build_livecomments_collection('title', 'articleId', 'http://livefyre.com')
    collection.data.tags = 'tags'
    expect(collection.build_checksum).to eq('8bcfca7fb2187b1dcb627506deceee32')
  end

  it 'should test basic site api' do
    name = "RubyCreateCollection#{Time.new}"

    collection = @site.build_livecomments_collection(name, name, URL).create_or_update
    content = collection.get_collection_content

    expect(collection.data.id).to eq(content['collectionSettings']['collectionId'])
  end
end