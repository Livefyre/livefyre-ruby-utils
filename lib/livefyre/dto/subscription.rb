require 'json'

module Livefyre
	class Subscription
    attr_accessor :to, :by, :type, :created_at
    
    def initialize(to, by, type, created_at=nil)
      @to = to
      @by = by
      @type = type
      @created_at = created_at
    end

    def self.serialize_from_json(json)
      new(json['to'], json['by'], json['type'], json['createdAt'])
    end

    def to_json(options = {})
      to_hash.to_json(options)
    end

    def to_hash
      hash = { :to => @to, :by => @by, :type => @type }
      if @created_at != nil
        hash[:createdAt] = @created_at
      end
      hash
    end
  end
end