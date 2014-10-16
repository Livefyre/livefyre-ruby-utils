module Livefyre
  class LivefyreUtil
    def self.uri?(string)
      uri = Addressable::URI.parse(string)
      %w( ftp ftps http https ).include?(uri.scheme)
    rescue Addressable::URI::BadURIError
      false
    rescue Addressable::URI::InvalidURIError
      false
    end
  end
end