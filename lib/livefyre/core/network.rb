require 'addressable/uri'
require 'jwt'
require 'rest-client'

require 'livefyre/api/personalized_streams'
require 'livefyre/core/site'
require 'livefyre/factory/cursor_factory'

module Livefyre
	class Network
		DEFAULT_USER = 'system'
		DEFAULT_EXPIRES = 86400

		def initialize(name, key)
			@name = name
			@key = key  
		end

		def set_user_sync_url(url_template)
			raise ArgumentError, 'url_template should contain {id}' if !url_template.include?('{id}')
			
			response =
				RestClient.post(
					"http://#{@name}",
					{ actor_token: build_livefyre_token, pull_profile_url: url_template }
				)
			response.code == 204
		end

		def sync_user(user_id)
			response =
				RestClient.post(
					"http://#{@name}/api/v3_0/user/#{user_id}/refresh",
					{ lftoken: build_livefyre_token }
				)
			response.code == 200
		end

		def build_livefyre_token
			build_user_auth_token(DEFAULT_USER, DEFAULT_USER, DEFAULT_EXPIRES)
		end

		def build_user_auth_token(user_id, display_name, expires)
			raise ArgumentError, 'user_id must be alphanumeric' if !(user_id =~ /\A\p{Alnum}+\z/)

			JWT.encode({
					domain: @name,
      user_id: user_id,
          display_name: display_name,
          expires: Time.new.to_i + expires},
          @key)
    end

    def validate_livefyre_token(lf_token)
      token_attributes = JWT.decode(lf_token, @key)

      token_attributes['domain'] == @name \
				&& token_attributes['user_id'] == DEFAULT_USER \
				&& token_attributes['expires'] >= Time.new.to_i
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
    def get_subscriptions(user)
        PersonalizedStreamsClient::get_subscriptions(self, user)
    end

    def add_subscriptions(user, topics)
        PersonalizedStreamsClient::post_subscriptions(self, user, topics)
    end

    def update_subscriptions(user, topics)
        PersonalizedStreamsClient::put_subscriptions(self, user, topics)
    end

    def remove_subscriptions(user, topics)
        PersonalizedStreamsClient::patch_subscriptions(self, user, topics)
    end

    # Subscriber API
    def get_subscribers(topic, limit=100, offset=0)
        PersonalizedStreamsClient::get_subscribers(self, topic, limit, offset)
    end

    # Timeline cursor
    def get_topic_stream_cursor(topic, limit=50)
        CursorFactory::get_topic_stream_cursor(self, topic, limit)
    end

    def get_personal_stream_cursor(user, limit=50)
        CursorFactory::get_personal_stream_cursor(self, user, limit)
    end

    def get_network_name
      @name
    end

    def get_urn
      "urn:livefyre:#{name}"
    end

    def get_user_urn(user)
      get_urn + ':user=' + user
    end

    def get_site(site_id, site_key)
      Site.new(self, site_id, site_key)
		end
	end
end