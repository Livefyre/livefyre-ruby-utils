# coding: utf-8

require 'livefyre'
require 'jwt'

describe Livefyre::Network do
	before(:each) do
		@network = Livefyre.get_network('networkName', 'networkKey')
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

describe Livefyre::Site do
	before(:each) do
		@site = Livefyre.get_network('networkName', 'networkKey').get_site('siteId', 'siteKey')
	end

	it 'should raise ArgumentError if url is not a valid url for cmt' do
		expect{ @site.build_collection_meta_token('test', 'test', 'blah.com/', 'test') }.to raise_error(ArgumentError)
	end

	it 'should raise ArgumentError if title is more than 255 characters for cmt' do
		expect{ @site.build_collection_meta_token('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', 'test', 'http://test.com', 'test') }.to raise_error(ArgumentError)
	end

	it 'should raise ArgumentError if not a valid type is passed in when building a collection meta token' do
		expect{ @site.build_collection_meta_token('', '', 'http://livefyre.com', '', 'bad type') }.to raise_error(ArgumentError)
	end

	it 'should check type and assign them to the correct field in the collection meta token' do
		@token = @site.build_collection_meta_token('', '', 'http://livefyre.com', '', 'reviews')
		@decoded = JWT.decode(@token, 'siteKey')

		expect(@decoded['type']).to eq('reviews')

		@token = @site.build_collection_meta_token('', '', 'http://livefyre.com', '', 'liveblog')
		@decoded = JWT.decode(@token, 'siteKey')

		expect(@decoded['type']).to eq('liveblog')
	end

	it 'should return a collection meta token' do
		expect{ @site.build_collection_meta_token('title', 'article_id', 'https://www.url.com', 'tags') }.to be_true
	end

	it 'should raise ArgumentError if url is not a valid url for checksum' do
		expect{ @site.build_checksum('test', 'blah.com/', 'test') }.to raise_error(ArgumentError)
	end

	it 'should raise ArgumentError if title is more than 255 characters for checksum' do
		expect{ @site.build_checksum('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', 'http://test.com', 'test') }.to raise_error(ArgumentError)
	end

	it 'should return a valid checksum' do
		expect(@site.build_checksum('title', 'https://www.url.com', 'tags')).to eq('4464458a10c305693b5bf4d43a384be7')
	end

	it 'should check for valid and invalid urls' do
		expect{ @site.build_checksum('', 'test.com', '') }.to raise_error(ArgumentError)
		
		@site.build_checksum('', 'http://localhost:8000', '')
		@site.build_checksum('', 'http://清华大学.cn', '')
		@site.build_checksum('', 'http://www.mysite.com/myresumé.html', '')
		@site.build_checksum('', 'https://test.com/', '')
		@site.build_checksum('', 'ftp://test.com/', '')
		@site.build_checksum('', "https://test.com/path/test.-_~!$&'()*+,;=:@/dash", '')
	end
end