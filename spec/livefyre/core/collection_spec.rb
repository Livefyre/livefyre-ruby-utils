require 'spec_helper'
require 'livefyre'
require 'jwt'
require 'livefyre/dto/topic'
require 'livefyre/exceptions/livefyre_exception'

include Livefyre

describe Livefyre::Collection do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end

  it 'should raise ArgumentError if article id, title, and/or url is blank' do
    expect{ @site.build_livecomments_collection('', ARTICLE_ID, URL) }.to raise_error(ArgumentError)
    expect{ @site.build_livecomments_collection(TITLE, '', URL) }.to raise_error(ArgumentError)
    expect{ @site.build_livecomments_collection(TITLE, ARTICLE_ID, '') }.to raise_error(ArgumentError)

    expect{ @site.build_collection(nil, nil, nil, nil) }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if url is not a valid url for collection' do
    expect{ @site.build_livecomments_collection(TITLE, ARTICLE_ID, 'blah.com/') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if title is more than 255 characters for collection' do
    expect{ @site.build_livecomments_collection('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', ARTICLE_ID, URL) }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if not a valid type is passed in when building a collection' do
    expect{ @site.build_collection('bad_type', TITLE, ARTICLE_ID, URL) }.to raise_error(ArgumentError)
  end

  it 'should check type and assign them to the correct field in the collection meta token' do
    @token = @site.build_reviews_collection(TITLE, ARTICLE_ID, URL).build_collection_meta_token
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('reviews')

    @token = @site.build_liveblog_collection(TITLE, ARTICLE_ID, URL).build_collection_meta_token
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('liveblog')
  end

  it 'should return a collection meta token' do
    expect(@site.build_livecomments_collection(TITLE, ARTICLE_ID, URL).build_collection_meta_token).to be_truthy
  end

  it 'should return a valid checksum' do
    collection = @site.build_livecomments_collection('title', 'articleId', 'http://livefyre.com')
    collection.data.tags = 'tags'
    expect(collection.build_checksum).to eq('8bcfca7fb2187b1dcb627506deceee32')
  end

  it 'should test network_issued properly' do
    collection = @site.build_livecomments_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.is_network_issued).to be false

    topics = [ Topic.create(@site, 'ID', 'LABEL') ]
    collection.data.topics = topics
    expect(collection.is_network_issued).to be false

    topics << Topic.create(@site.network, 'ID', 'LABEL')
    expect(collection.is_network_issued).to be true
  end

  it 'should throw an error when trying to retrieve collection id when it is not set' do
    collection = @site.build_livecomments_collection(TITLE, ARTICLE_ID, URL)
    expect{ collection.data.id }.to raise_error(LivefyreException)
  end

  it 'should product the correct urn for a collection' do
    collection = @site.build_livecomments_collection(TITLE, ARTICLE_ID, URL)
    collection.data.id = 1
    expect(collection.urn).to eq("#{@site.urn}:collection=1")
  end

  it 'should test basic site api' do
    name = "RubyCreateCollection#{Time.new}"

    collection = @site.build_livecomments_collection(name, name, URL).create_or_update
    content = collection.get_collection_content

    collection.data.title+='super'
    collection.create_or_update

    expect(collection.data.id).to eq(content['collectionSettings']['collectionId'])
  end
end