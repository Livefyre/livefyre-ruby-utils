require 'spec_helper'
require 'json'
require 'livefyre/dto/topic'

describe Livefyre::Topic do
  it 'should correctly form a hash' do
    topic = Livefyre::Topic.new('a', 'b')
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
    sub1 = Livefyre::Topic.new('a', 'b', 0, 1)
    json = sub1.to_json
    sub2 = JSON.parse(json)
    expect(sub1.to_hash).to eq(Livefyre::Topic::serialize_from_json(sub2).to_hash)
  end
end