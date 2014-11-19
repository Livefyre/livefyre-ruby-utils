require 'livefyre/core/network'

module Livefyre
	def self.get_network(network_name, network_key)
		Network.init(network_name, network_key)
	end
end