require 'addressable/uri'

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
    
    def self.get_network_from_core(core)
      if core.class.name == 'Livefyre::Collection'
        return core.site.network
      elsif core.class.name == 'Livefyre::Site'
        return core.network
      else
        return core
      end
    end
  end
end