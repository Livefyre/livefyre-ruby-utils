module Livefyre
	class Subscription
    def initialize(to, by, type, created_at=nil)
      @to = to
      @by = by
      @type = type
      @created_at = created_at
    end

    attr_reader :to
    attr_reader :by
    attr_reader :type
    attr_reader :created_at

    def self.serialize_from_json(json)
      new(json['to'], json['by'], json['type'], json['createdAt'])
    end

    def to_dict
      dict = { :to => @to, :by => @by, :type => @type }
      if @created_at != nil
        dict[:createdAt] = @created_at
      end
      dict
    end

  end

  module SubscriptionType
    PERSONAL_STREAM = 1
  end
end