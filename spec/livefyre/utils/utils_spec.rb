# coding: utf-8

require 'spec_helper'
require 'livefyre'
require 'jwt'

describe Livefyre::LivefyreUtil do
  it 'should check for valid and invalid urls' do
    expect(Livefyre::LivefyreUtil::uri?('test.com')).to eq(false)
  
    expect(Livefyre::LivefyreUtil::uri?('http://localhost:8000')).to eq(true)
    expect(Livefyre::LivefyreUtil::uri?('http://清华大学.cn')).to eq(true)
    expect(Livefyre::LivefyreUtil::uri?('http://www.mysite.com/myresumé.html')).to eq(true)
    expect(Livefyre::LivefyreUtil::uri?('https://test.com/')).to eq(true)
    expect(Livefyre::LivefyreUtil::uri?('ftp://test.com/')).to eq(true)
    expect(Livefyre::LivefyreUtil::uri?("https://test.com/path/test.-_~!$&'()*+,;=:@/dash")).to eq(true)
  end

  it 'should get network from all core objects' do
    network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
    site = network.get_site(SITE_ID, SITE_KEY)
    collection = site.build_livecomments_collection(TITLE, ARTICLE_ID, URL)

    expect(Livefyre::LivefyreUtil::get_network_from_core(network)).to eq(network)
    expect(Livefyre::LivefyreUtil::get_network_from_core(site)).to eq(network)
    expect(Livefyre::LivefyreUtil::get_network_from_core(collection)).to eq(network)
  end
end