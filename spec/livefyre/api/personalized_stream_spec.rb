require 'livefyre/spec_helper'
require 'livefyre'
require 'jwt'
require 'livefyre/api/personalized_stream'
require 'livefyre/factory/cursor_factory'

describe Livefyre::PersonalizedStream do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
    @site = @network.get_site(SITE_ID, SITE_KEY)
  end

  it 'should test that personalized streams api work for topics' do
    Livefyre::PersonalizedStream::create_or_update_topic(@network, 1, 'EINS')
    topic = Livefyre::PersonalizedStream::get_topic(@network, 1)
    Livefyre::PersonalizedStream::delete_topic(@network, topic).should == true

    Livefyre::PersonalizedStream::create_or_update_topics(@network, {1 => 'EINS', 2 => 'ZWEI'})
    topics = Livefyre::PersonalizedStream::get_topics(@network)
    Livefyre::PersonalizedStream::delete_topics(@network, topics)
  end

  it 'should test that personalized streams api work for subscriptions' do
    topics = Livefyre::PersonalizedStream::create_or_update_topics(@network, {1 => 'EINS', 2 => 'ZWEI'})
    user_token = @network.build_user_auth_token(USER_ID, "#{USER_ID}@#{NETWORK_NAME}", Livefyre::Network::DEFAULT_EXPIRES)

    Livefyre::PersonalizedStream::add_subscriptions(@network, user_token, topics)
    Livefyre::PersonalizedStream::get_subscriptions(@network, USER_ID)
    Livefyre::PersonalizedStream::replace_subscriptions(@network, user_token, [topics[1]])
    Livefyre::PersonalizedStream::get_subscribers(@network, topics[1])
    Livefyre::PersonalizedStream::remove_subscriptions(@network, user_token, [topics[1]])
  end

  it 'should test that personalized streams api work for timelines and cursors' do
    topic = Livefyre::PersonalizedStream::create_or_update_topic(@network, 1, 'EINS')
    cursor = Livefyre::CursorFactory::get_topic_stream_cursor(@network, topic)

    cursor.next
    cursor.previous

    Livefyre::PersonalizedStream::delete_topic(@network, topic)
  end

  it 'should test that personalized streams api work for topics' do
    Livefyre::PersonalizedStream::create_or_update_topic(@site, 1, 'EINS')
    topic = Livefyre::PersonalizedStream::get_topic(@site, 1)
    Livefyre::PersonalizedStream::delete_topic(@site, topic).should == true

    Livefyre::PersonalizedStream::create_or_update_topics(@site, {1 => 'EINS', 2 => 'ZWEI'})
    topics = Livefyre::PersonalizedStream::get_topics(@site)
    Livefyre::PersonalizedStream::delete_topics(@site, topics)
  end

  it 'should test that personalized streams api work for collections' do
    topics = Livefyre::PersonalizedStream::create_or_update_topics(@site, {1 => 'EINS', 2 => 'ZWEI'})
    name = "RUBY PSSTREAM TEST #{Time.new}"
    collection = @site.build_livecomments_collection(name, name, URL).create_or_update

    Livefyre::PersonalizedStream::add_collection_topics(collection, topics)
    Livefyre::PersonalizedStream::get_collection_topics(collection)
    Livefyre::PersonalizedStream::replace_collection_topics(collection, [topics[1]])
    Livefyre::PersonalizedStream::remove_collection_topics(collection, [topics[1]])
  end
end