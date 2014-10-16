require 'base64'
require 'digest'
require 'json'
require 'jwt'
require 'rest-client'
require 'addressable/uri'

require 'livefyre/api/domain'
require 'livefyre/core/collection'

module Livefyre
	class Site
    attr_reader :network
    attr_accessor :id, :key
    
		def initialize(network, id, key)
			@network = network
			@id = id
			@key = key
    end

    def build_collection(title, article_id, url, options={})
      Collection.new(self, title, article_id, url, options)
    end

    def build_livefyre_token
      @network.build_livefyre_token
    end

		def get_urn
			"#{@network.get_urn}:site=#{@id}"
		end
	end
end