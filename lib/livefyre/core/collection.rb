require 'base64'
require 'digest'
require 'json'
require 'jwt'
require 'rest-client'

require 'livefyre/api/domain'
require 'livefyre/exceptions/api_exception'
require 'livefyre/model/collection_data'
require 'livefyre/utils/livefyre_util'
require 'livefyre/validator/collection_validator'

module Livefyre
  class Collection
    attr_accessor :site, :data

    def initialize(site, data)
      @site = site
      @data = data
    end

    def self.init(site, type, title, article_id, url)
      data = CollectionData.new(type, title, article_id, url)
      Collection.new(site, CollectionValidator::validate(data))
    end
    
    def create_or_update
      response = invoke_collection_api('create')
      if response.code == 200
        @data.id = JSON.parse(response)['data']['collectionId']
        return self
      elsif response.code == 409
        response = invoke_collection_api('update')
        if response.code == 200
          return self
        end
      end
      raise ApiException.new(self, response.code)
    end

    def build_collection_meta_token
      attr = @data.as_hash
      attr[:iss] = is_network_issued ? @site.network.urn : @site.urn
      JWT.encode(attr, is_network_issued ? @site.network.data.key : @site.data.key)
    end

    def build_checksum
      attr_json = '{' + @data.as_hash.sort.map{|k,v| "#{k.inspect}:#{v.inspect}"}.join(',') + '}'
      Digest::MD5.new.update(attr_json).hexdigest
    end

    def get_collection_content
      response = RestClient.get(
          "#{Domain::bootstrap(self)}/bs3/#{@site.network.data.name}/#{@site.data.id}/#{Base64.encode64(@data.article_id.to_s).chomp}/init",
          :accepts => :json
        ){|response, request, result| response }
      raise ApiException.new(self, response.code) if response.code >= 400
      JSON.parse(response)
    end

    def urn
      "#{@site.urn}:collection=#{@data.id}"
    end

    def is_network_issued
      network_urn = @site.network.urn

      if @data.topics
        @data.topics.each do |topic|
          topic_id = topic.id
          if topic_id.start_with?(network_urn) && !topic_id.sub(network_urn, '').start_with?(':site=')
            return true
          end
        end
      end

      false
    end
    
    private

    def invoke_collection_api(method)
      uri = "#{Domain::quill(self)}/api/v3.0/site/#{@site.data.id}/collection/#{method}/?sync=1"
      data = {
        :articleId => @data.article_id,
        :collectionMeta => build_collection_meta_token,
        :checksum => build_checksum
      }
      headers = { :accepts => :json, :content_type => :json }
      RestClient.post(uri, data.to_json, headers){|response, request, result| response }
    end
  end
end