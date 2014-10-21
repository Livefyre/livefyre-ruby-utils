require 'spec_helper'
require 'json'
require 'livefyre/dto/subscription'

describe Livefyre::Subscription do
  it 'should correctly form a hash' do
    sub = Livefyre::Subscription.new('a', 'b', 'c')
    h = sub.to_hash
    expect(h[:to]).to eq('a')
    expect(h[:by]).to eq('b')
    expect(h[:type]).to eq('c')
    expect(h.has_key?(:createdAt)).to be false

    sub.created_at=0
    h = sub.to_hash
    expect(h[:createdAt]).to eq(0)
  end

  it 'should produce the expected json and serialize from it' do
    sub1 = Livefyre::Subscription.new('a', 'b', 'c')
    json = sub1.to_json
    sub2 = JSON.parse(json)
    expect(sub1.to_hash).to eq(Livefyre::Subscription::serialize_from_json(sub2).to_hash)
  end
end