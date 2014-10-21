require 'spec_helper'
require 'livefyre'
require 'jwt'
require 'livefyre/type/collection_type'

include Livefyre

describe Livefyre::Site do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end

  it 'should verify the urn' do
    expect(@site.urn).to eq("#{@site.network.urn}:site=#{SITE_ID}")
  end

  it 'should create collections of all types and verify their type' do
    collection = @site.build_livecomments_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::LIVECOMMENTS)
    collection = @site.build_liveblog_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::LIVEBLOG)
    collection = @site.build_livechat_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::LIVECHAT)
    collection = @site.build_counting_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::COUNTING)
    collection = @site.build_ratings_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::RATINGS)
    collection = @site.build_reviews_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::REVIEWS)
    collection = @site.build_sidenotes_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::SIDENOTES)
    collection = @site.build_collection(CollectionType::LIVECOMMENTS, TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::LIVECOMMENTS)
  end
end