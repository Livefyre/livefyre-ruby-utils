require 'spec_helper'
require 'json'
require 'livefyre/dto/topic'
require 'livefyre'

include Livefyre

describe Livefyre::Topic do
  it 'should correctly form a hash' do
    topic = Topic.new('a', 'b')
    h = topic.to_hash
    expect(h[:id]).to eq('a')
    expect(h[:label]).to eq('b')
    expect(h.has_key?(:createdAt)).to be false
    expect(h.has_key?(:modifiedAt)).to be false

    topic.created_at=0
    topic.modified_at=1
    h = topic.to_hash
    expect(h[:createdAt]).to eq(0)
    expect(h[:modifiedAt]).to eq(1)
  end

  it 'should produce the expected json and serialize from it' do
    topic = Topic.new('a', 'b', 0, 1)
    json = topic.to_json
    topic2 = JSON.parse(json)
    expect(topic.to_hash).to eq(Topic::serialize_from_json(topic2).to_hash)
  end

  it 'should retrieve the correct truncated id from a Topic' do
    topic = Topic.create(Livefyre.get_network(NETWORK_NAME, NETWORK_KEY), 'ID', 'LABEL')
    expect(topic.truncated_id).to eq('ID')
  end
end