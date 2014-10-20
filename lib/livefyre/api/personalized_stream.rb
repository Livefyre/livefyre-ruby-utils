require 'json'
require 'jwt'
require 'rest-client'

require 'livefyre/api/domain'
require 'livefyre/dto/topic'
require 'livefyre/dto/subscription'
require 'livefyre/exception/livefyre_exception'
require 'livefyre/type/subscription_type'
require 'livefyre/utils/livefyre_util'

module Livefyre
	class PersonalizedStream
		# Topic API
		def self.get_topic(core, topic_id)
			url =  self.base_url(core) + self.topic_path(core, topic_id)

			response = RestClient.get(url, self.get_headers(core))
      data = self.analyze_response(response)

      Topic::serialize_from_json(data['topic'])
    end

    def self.create_or_update_topic(core, topic_id, label)
      PersonalizedStream::create_or_update_topics(core, { "#{topic_id}" => label })[0]
    end

    def self.delete_topic(core, topic)
      PersonalizedStream::delete_topics(core, [topic]) == 1
    end

		# Multiple Topic API
		def self.get_topics(core, limit=100, offset=0)
			url = self.base_url(core) + self.multiple_topic_path(core)
      url += "?limit=#{limit}&offset=#{offset}"

      response = RestClient.get(url, self.get_headers(core))
      data = self.analyze_response(response)

      topics = []
      data['topics'].each do |topic|
        topics << Topic::serialize_from_json(topic)
      end

      topics
		end

		def self.create_or_update_topics(core, topic_map)
      topics = []

      topic_map.each do |key, value|
        if not value or value.length > 128
            raise ArgumentError, 'label cannot be longer than 128 chars.'
        end
        topics << Topic::create(core, key, value)
      end

			url = self.base_url(core) + self.multiple_topic_path(core)
      headers = self.get_headers(core)
      headers[:content_type] = :json

      topics_json = []
      topics.each do |topic|
        topics_json << topic.to_hash
      end

      response = RestClient.post(url, { :topics => topics_json }.to_json, headers)
      self.analyze_response(response)

      return topics
		end

		def self.delete_topics(core, topics)
			url = self.base_url(core) + self.multiple_topic_path(core)
      headers = self.get_headers(core)
      headers[:content_type] = :json
      form = { :delete => self.get_ids(topics) }

      response = RestClient.patch(url, form.to_json, headers)
      data = self.analyze_response(response)

      data.has_key?('deleted') ? data['deleted'] : 0
		end

		# Collection Topic API
		def self.get_collection_topics(collection)
			url = self.base_url(collection) + self.multiple_topic_path(collection)

      response = RestClient.get(url, self.get_headers(collection))
      data = self.analyze_response(response)

      data.has_key?('topicIds') ? data['topicIds'] : []
		end

		def self.add_collection_topics(collection, topics)
			url = self.base_url(collection) + self.multiple_topic_path(collection)
      headers = self.get_headers(collection)
      headers[:content_type] = :json
      form = { :topicIds => self.get_ids(topics) }

      response = RestClient.post(url, form.to_json, headers)
      data = self.analyze_response(response)

      data.has_key?('added') ? data['added'] : 0
		end

		def self.replace_collection_topics(collection, topics)
			url = self.base_url(collection) + self.multiple_topic_path(collection)
      headers = self.get_headers(collection)
      headers[:content_type] = :json
      form = { :topicIds => self.get_ids(topics) }

      response = RestClient.put(url, form.to_json, headers)
      data = self.analyze_response(response)

      return data.has_key?('added') ? data['added'] : 0, data.has_key?('removed') ? data['removed'] : 0
		end

		def self.remove_collection_topics(collection, topics)
			url = self.base_url(collection) + self.multiple_topic_path(collection)
      headers = self.get_headers(collection)
      headers[:content_type] = :json
      form = { :delete => self.get_ids(topics) }

      response = RestClient.patch(url, form.to_json, headers)
      data = self.analyze_response(response)

      data.has_key?('removed') ? data['removed'] : 0
		end

		# Subscription API
		def self.get_subscriptions(network, user_id)
			url = self.base_url(network) + self.user_subscription_path(network.get_urn_for_user(user_id))

      response = RestClient.get(url, self.get_headers(network))
      data = self.analyze_response(response)

      subscriptions = []
      if data.has_key?('subscriptions')
        data['subscriptions'].each do |sub_json|
          subscriptions << Subscription::serialize_from_json(sub_json)
        end
      end

      subscriptions
		end

		def self.add_subscriptions(network, user_token, topics)
      user_id = JWT.decode(user_token, network.data.key)['user_id']
      user_urn = network.get_urn_for_user(user_id)
      
			url = self.base_url(network) + self.user_subscription_path(user_urn)
      headers = self.get_headers(network, user_token)
      headers[:content_type] = :json
      form = { :subscriptions => self.to_subscriptions(topics, user_urn) }

      response = RestClient.post(url, form.to_json, headers)
      data = self.analyze_response(response)

      data.has_key?('added') ? data['added'] : 0
		end

		def self.replace_subscriptions(network, user_token, topics)
      user_id = JWT.decode(user_token, network.data.key)['user_id']
      user_urn = network.get_urn_for_user(user_id)
      
			url = self.base_url(network) + self.user_subscription_path(user_urn)
      headers = self.get_headers(network, user_token)
      headers[:content_type] = :json
      form = { :subscriptions => self.to_subscriptions(topics, user_urn) }

      response = RestClient.put(url, form.to_json, headers)
      data = self.analyze_response(response)

      return data.has_key?('added') ? data['added'] : 0, data.has_key?('removed') ? data['removed'] : 0
		end

		def self.remove_subscriptions(network, user_token, topics)
      user_id = JWT.decode(user_token, network.data.key)['user_id']
      user_urn = network.get_urn_for_user(user_id)
      
			url = self.base_url(network) + self.user_subscription_path(user_urn)
      headers = self.get_headers(network, user_token)
      headers[:content_type] = :json
      form = { :delete => self.to_subscriptions(topics, user_urn) }

      response = RestClient.patch(url, form.to_json, headers)
      data = self.analyze_response(response)

      data.has_key?('removed') ? data['removed'] : 0
		end

		def self.get_subscribers(network, topic, limit=100, offset=0)
			url = self.base_url(network) + self.topic_subscription_path(topic)
      url += "?limit=#{limit}&offset=#{offset}"

      response = RestClient.get(url, self.get_headers(network))
      data = self.analyze_response(response)

      subscriptions = []
      if data.has_key?('subscriptions')
        data['subscriptions'].each do |sub_json|
          subscriptions << Subscription::serialize_from_json(sub_json)
        end
      end

      subscriptions
		end

		# Stream API
		def self.get_timeline_stream(cursor, is_next)
			url = self.stream_base_url(cursor.core) + TIMELINE_PATH
      url += "?resource=#{cursor.data.resource}&limit=#{cursor.data.limit}"

      if is_next
        url += "&since=#{cursor.data.cursor_time}"
      else
        url += "&until=#{cursor.data.cursor_time}"
      end

      response = RestClient.get(url, self.get_headers(cursor.core))
      raise ApiException.new(self, response.code) if response.code >= 400
      JSON.parse(response)
    end

    private

    def self.base_url(core)
      "#{Domain::quill(core)}/api/v4"
    end

    def self.stream_base_url(core)
      "#{Domain::bootstrap(core)}/api/v4"
    end

    def self.topic_path(core, topic_id)
      "/#{Topic.generate_urn(core, topic_id)}/"
    end

    def self.multiple_topic_path(core)
      "/#{core.urn}:topics/"
    end

    def self.user_subscription_path(user_urn)
      "/#{user_urn}:subscriptions/"
    end

    def self.topic_subscription_path(topic)
      "/#{topic.id}:subscribers/"
    end

    TIMELINE_PATH = '/timeline/'

    def self.get_headers(core, user_token=nil)
      network = LivefyreUtil::get_network_from_core(core)
      {:accepts => :json, :authorization => 'lftoken ' + (user_token == nil ? network.build_livefyre_token : user_token)}
    end

    def self.get_ids(topics)
      ids = []
      topics.each do |topic|
          ids << topic.id
      end

      ids
    end

    def self.to_subscriptions(topics, user)
      subscriptions = []
      topics.each do |topic|
        subscriptions << Subscription.new(topic.id, user, SubscriptionType::PERSONAL_STREAM).to_hash
      end
      subscriptions
    end

    def self.analyze_response(response)
      raise ApiException.new(self, response.code) if response.code >= 400
      JSON.parse(response)['data']
    end
	end
end