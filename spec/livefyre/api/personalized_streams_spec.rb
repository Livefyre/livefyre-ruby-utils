require 'livefyre'
require 'jwt'
require 'livefyre/api/personalized_streams'
require 'livefyre/factory/cursor_factory'

RSpec.configure do |c|
  c.filter_run_excluding :broken => true
end

describe Livefyre::Network, :broken => true do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
    @site = @network.get_site(SITE_ID, SITE_KEY)
  end

  it 'should test that personalized streams api work for topics' do
    Livefyre::PersonalizedStreamsClient::create_or_update_topic(@network, 1, 'EINS')
    topic = Livefyre::PersonalizedStreamsClient::get_topic(@network, 1)
    Livefyre::PersonalizedStreamsClient::delete_topic(@network, topic).should == true

    Livefyre::PersonalizedStreamsClient::create_or_update_topics(@network, {1 => 'EINS', 2 => 'ZWEI'})
    topics = Livefyre::PersonalizedStreamsClient::get_topics(@network)
    Livefyre::PersonalizedStreamsClient::delete_topics(@network, topics)
  end

  it 'should test that personalized streams api work for subscriptions' do
    topics = Livefyre::PersonalizedStreamsClient::create_or_update_topics(@network, {1 => 'EINS', 2 => 'ZWEI'})

    Livefyre::PersonalizedStreamsClient::add_subscriptions(@network, USER_ID, topics)
    Livefyre::PersonalizedStreamsClient::get_subscriptions(@network, USER_ID)
    Livefyre::PersonalizedStreamsClient::replace_subscriptions(@network, USER_ID, [topics[1]])
    Livefyre::PersonalizedStreamsClient::get_subscribers(@network, topics[1])
    Livefyre::PersonalizedStreamsClient::remove_subscriptions(@network, USER_ID, [topics[1]])
  end

  it 'should test that personalized streams api work for timelines and cursors' do
    topic = Livefyre::PersonalizedStreamsClient::create_or_update_topic(@network, 1, 'EINS')
    cursor = Livefyre::CursorFactory::get_topic_stream_cursor(@network, topic)

    cursor.next
    cursor.previous

    Livefyre::PersonalizedStreamsClient::delete_topic(@network, topic)
  end

  it 'should test that personalized streams api work for topics' do
    Livefyre::PersonalizedStreamsClient::create_or_update_topic(@site, 1, 'EINS')
    topic = Livefyre::PersonalizedStreamsClient::get_topic(@site, 1)
    Livefyre::PersonalizedStreamsClient::delete_topic(@site, topic).should == true

    Livefyre::PersonalizedStreamsClient::create_or_update_topics(@site, {1 => 'EINS', 2 => 'ZWEI'})
    topics = Livefyre::PersonalizedStreamsClient::get_topics(@site)
    Livefyre::PersonalizedStreamsClient::delete_topics(@site, topics)
  end

  it 'should test that personalized streams api work for collections' do
    topics = Livefyre::PersonalizedStreamsClient::create_or_update_topics(@site, {1 => 'EINS', 2 => 'ZWEI'})

    Livefyre::PersonalizedStreamsClient::add_collection_topics(@site, COLLECTION_ID, topics)
    Livefyre::PersonalizedStreamsClient::get_collection_topics(@site, COLLECTION_ID)
    Livefyre::PersonalizedStreamsClient::replace_collection_topics(@site, COLLECTION_ID, [topics[1]])
    Livefyre::PersonalizedStreamsClient::remove_collection_topics(@site, COLLECTION_ID, [topics[1]])
  end
end