module Livefyre
  class SiteData
    attr_accessor :id, :key

    def initialize(id, key)
      @id = id
      @key = key
    end
  end
end