require 'livefyre/spec_helper'
require 'livefyre'
require 'jwt'

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
end