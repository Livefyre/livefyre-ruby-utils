# coding: utf-8

require 'livefyre'
require 'jwt'

RSpec.configure do |c|
  c.filter_run_excluding :broken => true
end

describe Livefyre::Collection do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end

  it 'should raise ArgumentError if url is not a valid url for collection' do
    expect{ @site.build_collection('test', 'test', 'blah.com/', 'test') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if title is more than 255 characters for collection' do
    expect{ @site.build_collection('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', 'test', 'http://test.com', 'test') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if not a valid type is passed in when building a collection' do
    expect{ @site.build_collection('', '', 'http://livefyre.com', {type: 'bad type'}) }.to raise_error(ArgumentError)
  end

  it 'should check type and assign them to the correct field in the collection meta token' do
    @token = @site.build_collection('', '', 'http://livefyre.com', {tags: '', type: 'reviews'}).build_collection_meta_token
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('reviews')

    @token = @site.build_collection('', '', 'http://livefyre.com', {type: 'liveblog'}).build_collection_meta_token
    @decoded = JWT.decode(@token, SITE_KEY)

    expect(@decoded['type']).to eq('liveblog')
  end

  it 'should return a collection meta token' do
    expect{ @site.build_collection('title', 'article_id', 'https://www.url.com', 'tags').build_collection_meta_token }.to be_true
  end

  it 'should return a valid checksum' do
    expect(@site.build_collection('title', 'https://www.url.com', 'tags').build_checksum).to eq('4464458a10c305693b5bf4d43a384be7')
  end

  it 'should test basic site api', :broken => true do
    @site.get_collection_content(ARTICLE_ID)

    name = "RubyCreateCollection#{Time.new}"
    id = @site.create_collection(name, name, 'http://answers.livefyre.com/RUBY')
    expect(@site.get_collection_id(name)).to eq(id)
  end
end