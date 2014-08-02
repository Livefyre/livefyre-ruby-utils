require 'addressable/uri'
require 'jwt'
require 'rest-client'

require 'livefyre/core/site'

module Livefyre
	class Network
		DEFAULT_USER = 'system'
		DEFAULT_EXPIRES = 86400

		def initialize(name, key)
			@name = name
			@key = key
      @network_name = name.split('.')[0]
    end
    attr_reader :name
    attr_reader :network_name

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

    def get_site(site_id, site_key)
      Site.new(self, site_id, site_key)
    end

    def get_urn
      "urn:livefyre:#{@name}"
    end

    def get_user_urn(user)
      "#{get_urn}:user=#{user}"
    end
	end
end