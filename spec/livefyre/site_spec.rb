# coding: utf-8

require 'livefyre'
require 'jwt'

RSpec.configure do |c|
  c.filter_run_excluding :broken => true
end

describe Livefyre::Site do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end

  it 'should raise ArgumentError if url is not a valid url for cmt' do
    expect{ @site.build_collection_meta_token('test', 'test', 'blah.com/', 'test') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if title is more than 255 characters for cmt' do
    expect{ @site.build_collection_meta_token('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', 'test', 'http://test.com', 'test') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if not a valid type is passed in when building a collection meta token' do
    expect{ @site.build_collection_meta_token('', '', 'http://livefyre.com', {type: 'bad type'}) }.to raise_error(ArgumentError)
  end

  it 'should check type and assign them to the correct field in the collection meta token' do
    @token = @site.build_collection_meta_token('', '', 'http://livefyre.com', {tags: '', type: 'reviews'})
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('reviews')

    @token = @site.build_collection_meta_token('', '', 'http://livefyre.com', {type: 'liveblog'})
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('liveblog')
  end

  it 'should return a collection meta token' do
    expect{ @site.build_collection_meta_token('title', 'article_id', 'https://www.url.com', 'tags') }.to be_true
  end

  it 'should raise ArgumentError if url is not a valid url for checksum' do
    expect{ @site.build_checksum('test', 'blah.com/', 'test') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if title is more than 255 characters for checksum' do
    expect{ @site.build_checksum('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', 'http://test.com', 'test') }.to raise_error(ArgumentError)
  end

  it 'should return a valid checksum' do
    expect(@site.build_checksum('title', 'https://www.url.com', 'tags')).to eq('4464458a10c305693b5bf4d43a384be7')
  end

  it 'should check for valid and invalid urls' do
    expect{ @site.build_checksum('', 'test.com', '') }.to raise_error(ArgumentError)

    @site.build_checksum('', 'http://localhost:8000', '')
    @site.build_checksum('', 'http://清华大学.cn', '')
    @site.build_checksum('', 'http://www.mysite.com/myresumé.html', '')
    @site.build_checksum('', 'https://test.com/', '')
    @site.build_checksum('', 'ftp://test.com/', '')
    @site.build_checksum('', "https://test.com/path/test.-_~!$&'()*+,;=:@/dash", '')
  end

  it 'should test that personalized streams api work for topics', :broken => true do
    @site.create_or_update_topic(1, 'EINS')
    topic = @site.get_topic(1)
    @site.delete_topic(topic).should == true

    @site.create_or_update_topics({1 => 'EINS', 2 => 'ZWEI'})
    topics = @site.get_topics
    @site.delete_topics(topics)
  end

  it 'should test that personalized streams api work for collections', :broken => true do
    topics = @site.create_or_update_topics({1 => 'EINS', 2 => 'ZWEI'})

    @site.add_collection_topics(COLLECTION_ID, topics)
    @site.get_collection_topics(COLLECTION_ID)
    @site.update_collection_topics(COLLECTION_ID, [topics[1]])
    @site.remove_collection_topics(COLLECTION_ID, [topics[1]])
  end
end