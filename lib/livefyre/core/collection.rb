require 'base64'
require 'digest'
require 'json'
require 'jwt'
require 'rest-client'
require 'addressable/uri'

require 'livefyre/api/domain'
require 'livefyre/utils/livefyre_util'
require 'livefyre/exceptions/livefyre_exception'

module Livefyre
  class Collection
    TYPE = %w(reviews sidenotes ratings counting liveblog livechat livecomments)

    attr_reader :site
    attr_accessor :title, :article_id, :url, :options, :network_issued

    def initialize(site, title, article_id, url, options)
      raise ArgumentError, 'provided url is not a valid url' if !LivefyreUtil::uri?(url)
      raise ArgumentError, 'title length should be under 255 char' if title.length > 255

      if options.has_key?(:type) && !TYPE.include?(options[:type])
        raise ArgumentError, "type is not a recognized type. should be in #{TYPE}, or an empty string"
      end
      if options.has_key?(:topics)
        @network_issued = check_topics(site.network.get_urn, options[:topics])
      else
        @network_issued = false
      end
      
      @site = site
      @title = title
      @article_id = article_id
      @url = url
      @options = options
    end
    
    def create_or_update
      response = invoke_collection_api('create')
      if response.code == 200
        @collection_id = JSON.parse(response)['data']['collectionId']
        return self
      elsif response.code == 409
        response = invoke_collection_api('update')
        if response.code = 200
          return self
        end
        raise LivefyreException, "Error updating Livefyre collection. Status code: #{response.code} \n Reason: #{response.content}"
      end
      raise LivefyreException, "Error creating Livefyre collection. Status code: #{response.code} \n Reason: #{response.content}"
    end

    def build_collection_meta_token
      attr = get_attr
      attr[:iss] = @network_issued ? @site.network.get_urn : @site.get_urn 
      JWT.encode(attr, @network_issued ? @site.network.key : @site.key)
    end

    def build_checksum
      attr_json = "{" + get_attr.sort.map{|k,v| "\"#{k.inspect}\":\"#{v.inspect}\""}.join(",") + "}"
      Digest::MD5.new.update(attr_json).hexdigest
    end

    def get_collection_content
      response = RestClient.get(
          "#{Domain::bootstrap(self)}/bs3/#{@site.network.name}/#{@site.id}/#{Base64.encode64(@article_id.to_s).chomp}/init",
          :accepts => :json
        )
      raise LivefyreException, '' if response.code != 200 
      JSON.parse(response)
    end

    def collection_id
      raise LivefyreException, "Call createOrUpdate() to set the collection id." if !defined? @collection_id
      @collection_id
    end

    def build_livefyre_token
      @site.build_livefyre_token
    end

    def get_urn
      "#{@site.get_urn}:collection=#{@collection_id}"
    end
    
    private

    def invoke_collection_api(method)
      uri = "#{Domain::quill(self)}/api/v3.0/site/#{@site.id}/collection/#{method}/?sync=1"
      data = {
        articleId: @article_id,
        collectionMeta: build_collection_meta_token(@title, @article_id, @url, @options),
        checksum: build_checksum(@title, @url, @options.has_key?(:tags) ? @options[:tags] : '')
      }
      headers = {:accepts => :json, :content_type => :json}

      response = RestClient.post(uri, data.to_json, headers)
      if response.code == 200
        return JSON.parse(response)['data']['collectionId']
      end

      nil
    end
    
    def get_payload
      { articleId: @article_id, collectionMeta: build_collection_meta_token(), checksum: build_checksum() }.to_json
    end
    
    def get_attr
      attr = options.clone
      attr[:articleId] = @article_id
      attr[:url] = @url
      attr[:title] = @title
      attr
    end
    
    def check_topics(network_urn, topics)
      topics.each do |topic|
        topic_id = topic.id
        if topic_id.start_with?(network_urn) && !topic_id.sub(network_urn, '').start_with?(':site=')
          return true
        end
      end
      false
    end
  end
end