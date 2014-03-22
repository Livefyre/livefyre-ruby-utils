require 'base64'
require 'json'
require 'jwt'
require 'rest-client'
require 'uri'

module Livefyre
	class Network
		DEFAULT_USER = 'system'
		DEFAULT_EXPIRES = 86400

		def initialize(network_name, network_key)
			@network_name = network_name
			@network_key = network_key  
		end

		def set_user_sync_url(url_template)
			raise ArgumentError, 'url_template should contain {id}' if !url_template.include?('{id}')
			
			response =
				RestClient.post(
					"http://#{@network_name}",
					{ actor_token: build_lf_token, pull_profile_url: url_template }
				)
			response.code == 204
		end

		def sync_user(user_id)
			response =
				RestClient.post(
					"http://#{@network_name}/api/v3_0/user/#{user_id}/refresh",
					{ lftoken: build_lf_token }
				)
			response.code == 200
		end

		def build_lf_token
			build_user_auth_token(DEFAULT_USER, DEFAULT_USER, DEFAULT_EXPIRES)
		end

		def build_user_auth_token(user_id, display_name, expires)
			raise ArgumentError, 'user_id must be alphanumeric' if !(user_id =~ /\A\p{Alnum}+\z/)

			JWT.encode({
					domain: @network_name,
					user_id: user_id,
					display_name: display_name,
					expires: Time.new.to_i + expires},
				@network_key)
		end
		
		def validate_livefyre_token(lf_token)
			token_attributes = JWT.decode(lf_token, @network_key)

			token_attributes['domain'] == @network_name \
				&& token_attributes['user_id'] == DEFAULT_USER \
				&& token_attributes['expires'] >= Time.new.to_i
		end
		
		def get_site(site_id, site_key)
			Site.new(@network_name, site_id, site_key)
		end

		class Site
			def initialize(network_name, site_id, site_key)
				@network_name = network_name
				@site_id = site_id
				@site_key = site_key
			end
	
			def build_collection_meta_token(title, article_id, url, tags, stream='')
				raise ArgumentError, 'provided url is not a valid url' if !uri?(url)
				raise ArgumentError, 'title length should be under 255 char' if title.length > 255
				JWT.encode({
						title: title,
						url: url,
						tags: tags,
						articleId: article_id,
						type: stream},
					@site_key)
			end
	
			def get_collection_content(article_id)
				response = 
					RestClient.get(
						"http://bootstrap.#{@network_name}/bs3/#{@network_name}/#{@site_id}/#{Base64.encode64(article_id.to_s()).chomp}/init",
						:accepts => :json
					)
				response.code == 200 ? JSON.parse(response) : nil
			end

			def uri?(string)
			  uri = URI.parse(string)
			  %w( http https ).include?(uri.scheme)
			rescue URI::BadURIError
			  false
			rescue URI::InvalidURIError
			  false
			end
		end
	end
end