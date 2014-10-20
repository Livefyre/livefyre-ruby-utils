# coding: utf-8

require 'livefyre/spec_helper'
require 'livefyre'
require 'jwt'

describe Livefyre::Domain do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end

  it 'should raise ArgumentError if url is not a valid url for collection' do
    expect{ @site.build_livecomments_collection('test', 'test', 'blah.com/') }.to raise_error(ArgumentError)
  end
end