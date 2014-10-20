# coding: utf-8

require 'livefyre/spec_helper'
require 'livefyre'
require 'jwt'

describe Livefyre::Site do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end
end