require 'spec_helper'
require 'livefyre'
require 'livefyre/cursor/timeline_cursor'

describe Livefyre::TimelineCursor do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
  end

  it 'should raise ArgumentError if any param is nil' do
    expect{ Livefyre::TimelineCursor::init(@network, nil, nil, Time.new) }.to raise_error(ArgumentError)
    expect{ Livefyre::TimelineCursor::init(@network, '', '', Time.new) }.to raise_error(ArgumentError)
  end

  it 'should set the same cursor time' do
    time = Time.new

    cursor = Livefyre::TimelineCursor::init(@network, 'resource', 50, time)
    set_time = cursor.data.cursor_time
    cursor.data.set_cursor_time(time)
    expect(cursor.data.cursor_time).to eq(set_time)
  end
end