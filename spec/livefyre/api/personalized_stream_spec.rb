require 'spec_helper'
require 'livefyre'
require 'jwt'
require 'livefyre/api/personalized_stream'
require 'livefyre/factory/cursor_factory'

include Livefyre

describe Livefyre::PersonalizedStream do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
    @site = @network.get_site(SITE_ID, SITE_KEY)
  end

  it 'should throw an exception if topic label does not fit the criteria' do
    expect{ PersonalizedStream::create_or_update_topic(@network, 1, '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890') }.to raise_error(ArgumentError)
  end

  it 'should test that personalized streams topic api work for networks' do
    PersonalizedStream::create_or_update_topic(@network, 1, 'EINS')
    topic = PersonalizedStream::get_topic(@network, 1)
    expect(PersonalizedStream::delete_topic(@network, topic)).to be true

    PersonalizedStream::create_or_update_topics(@network, {1 => 'EINS', 2 => 'ZWEI'})
    topics = PersonalizedStream::get_topics(@network)

    name = "RUBY PSSTREAM TEST #{Time.new}"
    collection = @site.build_comments_collection(name, name, URL)
    collection.data.topics = topics
    collection.create_or_update

    PersonalizedStream::delete_topics(@network, topics)
  end

  it 'should test that personalized streams topic api work for sites' do
    PersonalizedStream::create_or_update_topic(@site, 1, 'EINS')
    topic = PersonalizedStream::get_topic(@site, 1)
    expect(PersonalizedStream::delete_topic(@site, topic)).to be true

    PersonalizedStream::create_or_update_topics(@site, {1 => 'EINS', 2 => 'ZWEI'})
    topics = PersonalizedStream::get_topics(@site)

    name = "RUBY PSSTREAM TEST #{Time.new}"
    collection = @site.build_comments_collection(name, name, URL)
    collection.data.topics = topics
    collection.create_or_update

    PersonalizedStream::delete_topics(@site, topics)
  end

  it 'should test that personalized streams api work for subscriptions' do
    topics = PersonalizedStream::create_or_update_topics(@network, {1 => 'EINS', 2 => 'ZWEI'})
    user_token = @network.build_user_auth_token(USER_ID, "#{USER_ID}@#{NETWORK_NAME}", Network::DEFAULT_EXPIRES)

    PersonalizedStream::add_subscriptions(@network, user_token, topics)
    PersonalizedStream::get_subscriptions(@network, USER_ID)
    PersonalizedStream::replace_subscriptions(@network, user_token, [topics[1]])
    PersonalizedStream::get_subscribers(@network, topics[1])
    PersonalizedStream::remove_subscriptions(@network, user_token, [topics[1]])
  end

  it 'should test that personalized streams api work for timelines and cursors' do
    topic = PersonalizedStream::create_or_update_topic(@network, 1, 'EINS')
    cursor = CursorFactory::get_topic_stream_cursor(@network, topic)

    cursor.next
    cursor.previous

    PersonalizedStream::delete_topic(@network, topic)
  end

  it 'should test that personalized streams api work for collections' do
    topics = PersonalizedStream::create_or_update_topics(@site, {1 => 'EINS', 2 => 'ZWEI'})
    name = "RUBY PSSTREAM TEST #{Time.new}"
    collection = @site.build_comments_collection(name, name, URL).create_or_update

    PersonalizedStream::add_collection_topics(collection, topics)
    PersonalizedStream::get_collection_topics(collection)
    PersonalizedStream::replace_collection_topics(collection, [topics[1]])
    PersonalizedStream::remove_collection_topics(collection, [topics[1]])
  end
end