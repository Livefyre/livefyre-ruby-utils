module Livefyre
  class Domain
    def self.quill(core)
      begin
        ssl = core.ssl
      rescue
        ssl = core.network.ssl
      end
      ssl ? "https://#{core.network_name}.quill.fyre.co" : "http://quill.#{core.network_name}.fyre.co"
    end

    def self.bootstrap(core)
      begin
        ssl = core.ssl
      rescue
        ssl = core.network.ssl
      end
      ssl ? 'https://bootstrap.livefyre.com' : "http://bootstrap.#{core.network_name}.fyre.co"
    end
  end
end