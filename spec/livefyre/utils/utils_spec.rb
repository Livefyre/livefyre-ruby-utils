# coding: utf-8

require 'livefyre/spec_helper'
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
end