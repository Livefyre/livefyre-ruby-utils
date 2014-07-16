module Livefyre
	class Subscription
    def initialize(to, by, ype, created_at=nil)
      @to = to
      @by = by
      @type = type
      @created_at = created_at
    end

    def self.serialize_from_json(json)
      new(*json)
    end

    def serialize_to_json(*a)
      { :to => @to, :by => @by, :type => @type, :createdAt => @created_at }.to_json(*a)
    end

    class SubscriptionType
      personalStream = 1
    end
  end
end