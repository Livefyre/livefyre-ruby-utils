require 'base64'
require 'digest'
require 'json'
require 'jwt'
require 'rest-client'
require 'addressable/uri'

require 'livefyre/utils/livefyre_util'

module Livefyre
  class CollectionValidator
    def self.validate(data)
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

      data
    end
  end
end