module Livefyre
  class Domain
    def self.quill(core)
      network = self.get_network_from_(core)
      network.ssl ? "https://#{network.network_name}.quill.fyre.co" : "http://quill.#{network.name}"
    end

    def self.bootstrap(core)
      network = self.get_network_from_(core)
      network.ssl ? "https://#{network.network_name}.bootstrap.fyre.co" : "http://bootstrap.#{network.name}"
    end
    
    private
    
    def self.get_network_from_(core)
      begin
        network = core.site.network
      rescue
        network = core.network
      rescue
        network = core
      end
      network
    end
  end
end