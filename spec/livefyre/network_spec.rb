require 'livefyre'
require 'jwt'

RSpec.configure do |c|
  c.filter_run_excluding :broken => true
end

describe Livefyre::Network do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
  end

  it 'should raise ArgumentError if url_template does not contain {id}' do
    expect{ @network.set_user_sync_url('blah.com/') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if user_id is not alphanumeric' do
    expect{ @network.build_user_auth_token('fjoiwje.1fj', 'test', 100) }.to raise_error(ArgumentError)
  end

  it 'should validate a livefyre token' do
    @network.validate_livefyre_token(@network.build_livefyre_token).should == true
  end

  it 'should test that personalized streams api work for topics', :broken => true do
    @network.create_or_update_topic(1, 'EINS')
    topic = @network.get_topic(1)
    @network.delete_topic(topic).should == true

    @network.create_or_update_topics({1 => 'EINS', 2 => 'ZWEI'})
    topics = @network.get_topics
    @network.delete_topics(topics)
  end

  it 'should test that personalized streams api work for subscriptions', :broken => true do
    topics = @network.create_or_update_topics({1 => 'EINS', 2 => 'ZWEI'})

    @network.add_subscriptions(USER, topics)
    @network.get_subscriptions(USER)
    @network.update_subscriptions(USER, [topics[1]])
    @network.get_subscribers(topics[1])
    @network.remove_subscriptions(USER, [topics[1]])
  end

  it 'should test that personalized streams api work for timelines and cursors', :broken => true do
    topic = @network.create_or_update_topic(1, 'EINS')
    cursor = @network.get_topic_stream_cursor(topic)

    cursor.next
    cursor.previous
  end
end