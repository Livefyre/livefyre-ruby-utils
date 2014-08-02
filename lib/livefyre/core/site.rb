require 'base64'
require 'digest'
require 'json'
require 'jwt'
require 'rest-client'
require 'addressable/uri'

module Livefyre
	class Site
		TYPE = %w(reviews sidenotes ratings counting liveblog livechat livecomments)

		def initialize(network, id, key)
			@network = network
			@id = id
			@key = key
    end
    attr_reader :network
    attr_reader :id

		def build_collection_meta_token(title, article_id, url, options={})
			raise ArgumentError, 'provided url is not a valid url' if !uri?(url)
			raise ArgumentError, 'title length should be under 255 char' if title.length > 255
			
			collection_meta = {
				url: url,
				title: title,
				articleId: article_id
			}

			if options.has_key?(:type) && !TYPE.include?(options[:type])
        raise ArgumentError, 'type is not a recognized type. should be liveblog, livechat, livecomments, reviews, sidenotes, or an empty string'
			end

			JWT.encode(collection_meta.merge(options), @key)
		end

		def build_checksum(title, url, tags='')
			raise ArgumentError, 'provided url is not a valid url' if !uri?(url)
			raise ArgumentError, 'title length should be under 255 char' if title.length > 255
			
			collection_meta = { tags: tags, title: title, url: url }
			Digest::MD5.new.update(collection_meta.to_json).hexdigest
		end

		def get_collection_content(article_id)
			response = 
				RestClient.get(
					"https://bootstrap.livefyre.com/bs3/#{@network.name}/#{@id}/#{Base64.encode64(article_id.to_s).chomp}/init",
					:accepts => :json
				)
			response.code == 200 ? JSON.parse(response) : nil
		end

		def get_collection_id(article_id)
			content = get_collection_content(article_id)
			if content
				content['collectionSettings']['collectionId']
			end
    end

    def network_name
			@network.network_name
    end

    def build_livefyre_token
      @network.build_livefyre_token
    end

		def get_urn
			"#{@network.get_urn}:site=#{@id}"
		end

		def uri?(string)
		  uri = Addressable::URI.parse(string)
		  %w( ftp ftps http https ).include?(uri.scheme)
		rescue Addressable::URI::BadURIError
		  false
		rescue Addressable::URI::InvalidURIError
		  false
		end
	end
end