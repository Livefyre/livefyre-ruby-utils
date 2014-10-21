require 'spec_helper'
require 'livefyre'
require 'livefyre/factory/cursor_factory'

include Livefyre

describe Livefyre::CursorFactory do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
  end

  it 'should create a cursor with a personal stream resource' do
    topic = Topic.create(@network, 'ID', 'LABEL')
    cursor = CursorFactory.get_personal_stream_cursor(@network, USER_ID)
    expect(cursor.data.resource).to eq("#{@network.get_urn_for_user(USER_ID)}:personalStream")

    cursor = CursorFactory.get_personal_stream_cursor(@network, USER_ID, 10, Time.new)
    expect(cursor.data.limit).to eq(10)
  end

  it 'should create a cursor with a topic stream resource' do
    topic = Topic.create(@network, 'ID', 'LABEL')
    cursor = CursorFactory.get_topic_stream_cursor(@network, topic)
    expect(cursor.data.resource).to eq("#{topic.id}:topicStream")

    cursor = CursorFactory.get_topic_stream_cursor(@network, topic, 10, Time.new)
    expect(cursor.data.limit).to eq(10)
  end
end