# coding: utf-8

require 'livefyre'
require 'jwt'

RSpec.configure do |c|
c.filter_run_excluding :broken => true
end

describe Livefyre::Site do
  before(:each) do
    @site = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY).get_site(SITE_ID, SITE_KEY)
  end
end