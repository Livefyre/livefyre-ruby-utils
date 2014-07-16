require 'json'
require 'rest-client'
require 'addressable/uri'

require 'livefyre/entity/topic'

module Livefyre
	class PersonalizedStreamsClient
		# Topic API
		def self.get_topic(core, topic_id)
			url =  self.base_url(core) + self.topic_path(core, topic_id)

			response = RestClient.get(url, self.get_headers(core))
      data = JSON.parse(response)['data']

      Topic::serialize_from_json(data['topic'])
		end

		# Multiple Topic API
		def self.get_topics(core, limit=100, offset=0)
			url = self.base_url(core) + self.multiple_topic_path(core)
      url += "?limit=#{limit}&offset=#{offset}"

      response = RestClient.get(url, self.get_headers(core))
      data = JSON.parse(response)['data']

      topics = []
      data['topics'].each do |topic|
        topics << Topic::serialize_from_json(topic)
      end

      topics
		end

		def self.post_topics(core, topics)
			url = self.base_url(core) + self.multiple_topic_path(core)
      headers = self.get_headers(core)
      headers[:type => :json]

      response = RestClient.post(url, {:topics => topics}, headers)
      data = JSON.parse(response)['data']

      return data.has_key?('created') ? data['created'] : 0, data.has_key?('updated') ? data['updated'] : 0
		end

		def self.patch_topics(core, topics)
			url = self.base_url(core) + self.multiple_topic_path(core)
      headers = self.get_headers(core)
      headers[:type => :json]

      response = RestClient.patch(url, {:delete => self.get_ids(topics)}, headers)
      data = JSON.parse(response)['data']

      data.has_key?('deleted') ? data['deleted'] : 0
		end

		# Collection Topic API
		def self.get_collection_topics(site, collection_id)
			url = self.base_url(site) + self.collection_topics_path(site, collection_id)

      response = RestClient.get(url, self.get_headers(site))
      data = JSON.parse(response)['data']

      data.has_key?('topicIds') ? data['topicIds'] : []
		end

		def self.post_collection_topics(site, collection_id, topics)
			url = self.base_url(site) + self.collection_topics_path(site, collection_id)
      headers = self.get_headers(site)
      headers[:type => :json]

      response = RestClient.post(url, {:topics => self.get_ids(topics)}, headers)
      data = JSON.parse(response)['data']

      data.has_key?('added') ? data['added'] : 0
		end

		def self.put_collection_topics(site, collection_id, topics)
			url = self.base_url(site) + self.collection_topics_path(site, collection_id)
      headers = self.get_headers(site)
      headers[:type => :json]

      response = RestClient.post(url, {:topics => self.get_ids(topics)}, headers)
      data = JSON.parse(response)['data']

      return data.has_key?('added') ? data['added'] : 0, data.has_key?('removed') ? data['removed'] : 0
		end

		def self.patch_collection_topics(site, collection_id, topics)
			url = self.base_url(site) + self.collection_topics_path(site, collection_id)
      headers = self.get_headers(site)
      headers[:type => :json]

      response = RestClient.post(url, {:delete => self.get_ids(topics)}, headers)
      data = JSON.parse(response)['data']

      data.has_key?('removed') ? data['removed'] : 0
		end

		# Subscription API
		def self.get_subscriptions(network, user)
			url = self.base_url(network) + self.user_subscription_path(core, user)

      response = RestClient.get(url, self.get_headers(network))
      data = JSON.parse(response)['data']

      subscriptions = []
      if data.has_key?('subscriptions')
        data['subscriptions'].each do |sub_json|
          subscriptions << Subscription::serialize_from_json(sub_json)
        end
      end

      subscriptions
		end

		def self.post_subscriptions(network, user, topics)
			url = self.base_url(network) + self.user_subscription_path(core, user)
      headers = self.get_headers(network, user)
      headers[:type => :json]

      response = RestClient.post(url, {:topics => self.to_subscriptions(topics)}, headers)
      data = JSON.parse(response)['data']

      data.has_key?('added') ? data['added'] : 0
		end

		def self.put_subscriptions(network, user, topics)
			url = self.base_url(network) + self.user_subscription_path(core, user)
      headers = self.get_headers(network, user)
      headers[:type => :json]

      response = RestClient.post(url, {:topics => self.to_subscriptions(topics)}, headers)
      data = JSON.parse(response)['data']

      return data.has_key?('added') ? data['added'] : 0, data.has_key?('removed') ? data['removed'] : 0
		end

		def self.patch_subscriptions(network, user, topics)
			url = self.base_url(network) + self.user_subscription_path(core, user)
      headers = self.get_headers(network, user)
      headers[:type => :json]

      response = RestClient.post(url, {:delete => self.to_subscriptions(topics)}, headers)
      data = JSON.parse(response)['data']

      data.has_key?('removed') ? data['removed'] : 0
		end

		def self.get_subscribers(network, topic, limit=100, offset=0)
			url = self.base_url(network) + self.topic_subscription_path(topic)

      response = RestClient.get(url, self.get_headers(network))
      data = JSON.parse(response)['data']

      subscriptions = []
      if data.has_key?('subscriptions')
        data['subscriptions'].each do |sub_json|
          subscriptions << Subscription::serialize_from_json(sub_json)
        end
      end

      subscriptions
		end

		# Stream API
		def self.get_timeline_stream(core, resource, limit=50, t_until=nil, t_since=nil)
			url = self.stream_base_url(core) + self.timeline_path

      response = RestClient.get(url, self.get_headers(core))

      JSON.parse(response)
    end

    private

    def self.base_url(core)
      "http://quill.#{core.get_network_name}/api/v4"
    end

    def self.stream_base_url(core)
      "http://bootstrap.#{core.get_network_name}/api/v4"
    end

    def self.topic_path(core, topic_id)
      "/#{Topic.generate_urn(core, topic_id)}/"
    end

    def self.multiple_topic_path(core)
      "/#{core.get_urn}:topics/"
    end

    def self.collection_topics_path(site, collection_id)
      "/#{site.get_urn}:collection=#{collection_id}:topics/"
    end

    def self.user_subscription_path(network, user)
      "/#{network.get_user_urn(user)}:subscriptions/"
    end

    def self.topic_subscription_path(topic)
      "/#{topic.id}:subscribers/"
    end

    def self.timeline_path
      '/timeline/'
    end

    def self.get_headers(core, user=nil)
      token = user == nil ? core.build_livefyre_token : core.build_user_auth_token(user, nil, Network::DEFAULT_EXPIRES)
      {:accepts => :json, :authorization => 'lftoken ' + token}
    end

    def self.get_ids(topics)
      ids = []
      topics.each do |topic|
          ids << topic.id
      end

      ids
    end
	end
end