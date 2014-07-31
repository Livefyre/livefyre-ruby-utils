require 'base64'
require 'digest'
require 'json'
require 'jwt'
require 'rest-client'
require 'addressable/uri'

require 'livefyre/api/personalized_streams'

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

    # Topic API
    def get_topic(topic_id)
      PersonalizedStreamsClient::get_topic(self, topic_id)
    end

    def create_or_update_topic(topic_id, label)
      topic = Topic::create(self, topic_id, label)
      PersonalizedStreamsClient::post_topics(self, [topic])

      topic
    end

    def delete_topic(topic)
      PersonalizedStreamsClient::patch_topics(self, [topic]) == 1
    end

    # Multiple Topic API
    def get_topics(limit=100, offset=0)
      PersonalizedStreamsClient::get_topics(self, limit, offset)
    end

    def create_or_update_topics(topic_map)
      topics = []

      topic_map.each do |key, value|
        topics << Topic::create(self, key, value)
      end

      PersonalizedStreamsClient::post_topics(self, topics)

      topics
    end

    def delete_topics(topics)
      PersonalizedStreamsClient::patch_topics(self, topics)
    end

    # Subscription API
    def get_collection_topics(collection_id)
      PersonalizedStreamsClient::get_collection_topics(self, collection_id)
    end

    def add_collection_topics(collection_id, topics)
      PersonalizedStreamsClient::post_collection_topics(self, collection_id, topics)
    end

    def update_collection_topics(collection_id, topics)
      PersonalizedStreamsClient::put_collection_topics(self, collection_id, topics)
    end

    def remove_collection_topics(collection_id, topics)
      PersonalizedStreamsClient::patch_collection_topics(self, collection_id, topics)
    end

    # Timeline cursor
    def get_topic_stream_cursor(topic, limit=50, date=Time.new)
      CursorFactory::get_topic_stream_cursor(self, topic, limit, date)
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