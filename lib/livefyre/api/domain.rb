require 'livefyre/utils/livefyre_util'

module Livefyre
  class Domain
    def self.quill(core)
      network = LivefyreUtil::get_network_from_core(core)
      network.ssl ? "https://#{network.network_name}.quill.fyre.co" : "http://quill.#{network.network_name}.fyre.co"
    end

    def self.bootstrap(core)
      network = LivefyreUtil::get_network_from_core(core)
      network.ssl ? "https://#{network.network_name}.bootstrap.fyre.co" : "http://bootstrap.#{network.network_name}.fyre.co"
    end
  end
end