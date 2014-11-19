# coding: utf-8

require 'spec_helper'
require 'livefyre'
require 'jwt'

include Livefyre

describe Livefyre::LivefyreUtil do
  it 'should check for valid and invalid urls' do
    expect(LivefyreUtil::uri?('test.com')).to eq(false)
  
    expect(LivefyreUtil::uri?('http://localhost:8000')).to eq(true)
    expect(LivefyreUtil::uri?('http://清华大学.cn')).to eq(true)
    expect(LivefyreUtil::uri?('http://www.mysite.com/myresumé.html')).to eq(true)
    expect(LivefyreUtil::uri?('https://test.com/')).to eq(true)
    expect(LivefyreUtil::uri?('ftp://test.com/')).to eq(true)
    expect(LivefyreUtil::uri?("https://test.com/path/test.-_~!$&'()*+,;=:@/dash")).to eq(true)
  end

  it 'should get network from all core objects' do
    network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
    site = network.get_site(SITE_ID, SITE_KEY)
    collection = site.build_comments_collection(TITLE, ARTICLE_ID, URL)

    expect(LivefyreUtil::get_network_from_core(network)).to eq(network)
    expect(LivefyreUtil::get_network_from_core(site)).to eq(network)
    expect(LivefyreUtil::get_network_from_core(collection)).to eq(network)
  end
end