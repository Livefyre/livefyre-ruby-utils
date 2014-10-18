module Livefyre
	class Topic
    TOPIC_IDENTIFIER = ':topic='

    attr_accessor :id, :label, :created_at, :modified_at
    
    def initialize(id, label, created_at=nil, modified_at=nil)
      @id = id
      @label = label
      @created_at = created_at
      @modified_at = modified_at
    end

    def self.create(core, id, label)
      new(Topic::generate_urn(core, id), label)
    end

    def self.serialize_from_json(json)
      new(json['id'], json['label'], json['createdAt'], json['modifiedAt'])
    end

    def to_hash
      json = { :id => @id, :label => @label }
      if @created_at != nil
        json[:createdAt] = @created_at
      end

      if @modified_at != nil
        json[:modifiedAt] = @modified_at
      end

      json
    end

    def self.generate_urn(core, id)
      "#{core.urn}#{TOPIC_IDENTIFIER}#{id}"
    end

    def truncated_id
      @id[@id.index(TOPIC_IDENTIFIER) + TOPIC_IDENTIFIER.length]
    end
	end
end