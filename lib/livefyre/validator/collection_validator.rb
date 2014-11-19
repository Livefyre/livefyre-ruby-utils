require 'livefyre/utils/livefyre_util'

module Livefyre
  class CollectionValidator
    def self.validate(data)
      reason = ''

      reason += '\n Article id is null or blank' if data.article_id.to_s.empty?

      if data.title.to_s.empty?
        reason += '\n Title is null or blank'
      elsif data.title.length > 255
        reason += '\n Title is longer than 255 characters.'
      end

      if data.url.to_s.empty?
        reason += '\n URL is null or blank.'
      elsif !LivefyreUtil::uri?(data.url)
        reason += '\n URL is not a valid url. see http://www.ietf.org/rfc/rfc2396.txt'
      end

      if data.type == nil
        reason += '\n Type cannot be nil.'
      else
        print data.type.start_with?('live') ? data.type.sub('live', '').upcase : data.type.upcase
        if not CollectionType.const_defined?(data.type.start_with?('live') ? data.type.sub('live', '').upcase : data.type.upcase)
          reason += '\n Type must be of valid, recognized type. See CollectionType.'
        end
      end

      raise ArgumentError, "Problems with your collection input: #{reason}" if reason.length > 0

      data
    end
  end
end