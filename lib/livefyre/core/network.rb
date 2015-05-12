require 'jwt'
require 'rest-client'

require 'livefyre/api/domain'
require 'livefyre/core/site'
require 'livefyre/exceptions/api_exception'
require 'livefyre/model/network_data'
require 'livefyre/validator/network_validator'

module Livefyre
  class Network
    ALPHA_DASH_UNDER_DOT_REGEX = /^[a-zZA-Z0-9_\.-]+$/
    DEFAULT_USER = 'system'
    DEFAULT_EXPIRES = 86400

    attr_accessor :data, :ssl

    def initialize(data)
      @data = data
      @ssl = true
    end

    def self.init(name, key)
      data = NetworkData.new(name, key)
      Network.new(NetworkValidator::validate(data))
    end

    def set_user_sync_url(url_template)
      raise ArgumentError, 'url_template should contain {id}' if !url_template.include?('{id}')

      response = RestClient.post(
          "#{Domain::quill(self)}/",
          { :actor_token => build_livefyre_token, :pull_profile_url => url_template }
      ){|response, request, result| response }
      raise ApiException.new(self, response.code) if response.code >= 400
    end

    def sync_user(user_id)
      response = RestClient.post(
          "#{Domain::quill(self)}/api/v3_0/user/#{user_id}/refresh",
          { :lftoken => build_livefyre_token }
      ){|response, request, result| response }
      raise ApiException.new(self, response.code) if response.code >= 400
      self
    end

    def build_livefyre_token
      build_user_auth_token(DEFAULT_USER, DEFAULT_USER, DEFAULT_EXPIRES)
    end


    def build_user_auth_token(user_id, display_name, expires)
      raise ArgumentError, "userId is not alphanumeric. Ensure the following regex pattern is respected #{ALPHA_DASH_UNDER_DOT_REGEX}" if !(user_id =~ ALPHA_DASH_UNDER_DOT_REGEX)
      raise ArgumentError, 'expires must be a number' if !expires.is_a? Numeric

      JWT.encode({
          :domain => @data.name,
          :user_id => user_id,
          :display_name => display_name,
          :expires => Time.new.to_i + expires},
        @data.key)
    end

    def validate_livefyre_token(lf_token)
      claims, _ = JWT.decode(lf_token, @data.key)
      claims['domain'] == @data.name && claims['user_id'] == DEFAULT_USER && claims['expires'] >= Time.new.to_i
    end

    def get_site(site_id, site_key)
      Site::init(self, site_id, site_key)
    end

    def urn
      "urn:livefyre:#{@data.name}"
    end

    def get_urn_for_user(user)
      "#{urn}:user=#{user}"
    end

    def network_name
      @data.name.split('.')[0]
    end
  end
end