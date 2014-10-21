require 'spec_helper'
require 'livefyre'
require 'jwt'

describe Livefyre::Network do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
  end

  it 'should raise ArgumentError if any param is nil' do
    expect{ Livefyre.get_network(nil, nil) }.to raise_error(ArgumentError)
    expect{ Livefyre.get_network('', NETWORK_KEY) }.to raise_error(ArgumentError)
    expect{ Livefyre.get_network(NETWORK_NAME, '') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if network name does not end in \'fyre.co\'' do
    expect{ Livefyre.get_network('blah', NETWORK_KEY) }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if url_template does not contain {id}' do
    expect{ @network.set_user_sync_url('blah.com/') }.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError if user_id is not alphanumeric' do
    expect{ @network.build_user_auth_token('fjoiwje.1fj', 'test', 100) }.to raise_error(ArgumentError)
  end

  it 'should validate a livefyre token' do
    expect(@network.validate_livefyre_token(@network.build_livefyre_token)).to be true
  end

  it 'should verify the urn and user urn' do
    urn = "urn:livefyre:#{@network.data.name}"
    expect(@network.urn).to eq(urn)
    expect(@network.get_urn_for_user(USER_ID)).to eq("#{urn}:user=#{USER_ID}")
  end

  it 'should get the correct network name' do
    expect(@network.network_name).to eq(NETWORK_NAME.split('.')[0])
  end

  it 'should test network api calls' do
    @network.set_user_sync_url(URL+'/{id}')
    @network.sync_user(USER_ID)
  end
end