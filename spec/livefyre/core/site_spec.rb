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
    collection = @site.build_comments_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::COMMENTS)
    collection = @site.build_blog_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::BLOG)
    collection = @site.build_chat_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::CHAT)
    collection = @site.build_counting_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::COUNTING)
    collection = @site.build_ratings_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::RATINGS)
    collection = @site.build_reviews_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::REVIEWS)
    collection = @site.build_sidenotes_collection(TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::SIDENOTES)
    collection = @site.build_collection(CollectionType::COMMENTS, TITLE, ARTICLE_ID, URL)
    expect(collection.data.type).to eq(CollectionType::COMMENTS)
  end
end