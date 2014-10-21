require 'spec_helper'
require 'livefyre'
require 'livefyre/api/domain'
require 'jwt'

describe Livefyre::Domain do
  before(:each) do
    @network = Livefyre.get_network(NETWORK_NAME, NETWORK_KEY)
    @site = @network.get_site(SITE_ID, SITE_KEY)
    @collection = @site.build_livecomments_collection(TITLE, ARTICLE_ID, URL)
  end

  it 'should correctly form quill URLs from core objects' do
    quill_domain_ssl = "https://#{@network.network_name}.quill.fyre.co"
    expect(Livefyre::Domain::quill(@network)).to eq(quill_domain_ssl)
    expect(Livefyre::Domain::quill(@site)).to eq(quill_domain_ssl)
    expect(Livefyre::Domain::quill(@collection)).to eq(quill_domain_ssl)

    quill_domain = "http://quill.#{@network.network_name}.fyre.co"
    @network.ssl = false
    expect(Livefyre::Domain::quill(@network)).to eq(quill_domain)
    expect(Livefyre::Domain::quill(@site)).to eq(quill_domain)
    expect(Livefyre::Domain::quill(@collection)).to eq(quill_domain)
  end

  it 'should correctly form bootstrap URLs from core objects' do
    bootstrap_domain_ssl = "https://#{@network.network_name}.bootstrap.fyre.co"
    expect(Livefyre::Domain::bootstrap(@network)).to eq(bootstrap_domain_ssl)
    expect(Livefyre::Domain::bootstrap(@site)).to eq(bootstrap_domain_ssl)
    expect(Livefyre::Domain::bootstrap(@collection)).to eq(bootstrap_domain_ssl)

    bootstrap_domain = "http://bootstrap.#{@network.network_name}.fyre.co"
    @network.ssl = false
    expect(Livefyre::Domain::bootstrap(@network)).to eq(bootstrap_domain)
    expect(Livefyre::Domain::bootstrap(@site)).to eq(bootstrap_domain)
    expect(Livefyre::Domain::bootstrap(@collection)).to eq(bootstrap_domain)
  end
end