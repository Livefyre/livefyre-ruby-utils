module Livefyre
  class NetworkData
    attr_accessor :name, :key

    def initialize(name, key)
      @name = name
      @key = key
    end
  end
end