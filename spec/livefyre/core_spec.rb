require 'livefyre'

describe Livefyre::Network do
	before(:each) do
		@network = Livefyre.get_network('test.fyre.com', 'testkeytest')
	end

	it 'should raise ArgumentError if url_template does not contain {id}' do
		expect{ @network.set_user_sync_url('blah.com/') }.to raise_error(ArgumentError)
	end

	it 'should raise ArgumentError if user_id is not alphanumeric' do
		expect{ @network.build_user_auth_token('fjoiwje.1fj', 'test', 100) }.to raise_error(ArgumentError)
	end

	it 'should validate a livefyre token' do
		@network.validate_livefyre_token(@network.build_user_auth_token).should == true
	end
end

describe Livefyre::Network::Site do
	before(:each) do
		@site = Livefyre.get_network('test.fyre.com', 'testkeytest').get_site("site", "secret")
	end

	it 'should raise ArgumentError if url is not a valid url' do
		expect{ @site.build_collection_meta_token('test', 'test', 'blah.com/', 'test') }.to raise_error(ArgumentError)
	end

	it 'should raise ArgumentError if title is more than 255 characters' do
		expect{ @site.build_collection_meta_token('1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456', 'test', 'http://test.com', 'test') }.to raise_error(ArgumentError)
	end
end