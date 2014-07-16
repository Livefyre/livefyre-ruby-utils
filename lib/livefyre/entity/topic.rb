module Livefyre
	class Topic
    TOPIC_IDENTIFIER = ':topic='

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
      new(*json)
    end

    def serialize_to_json(*a)
      { :id => @id, :label => @label, :createdAt => @created_at, :modifiedAt => @modified_at }.to_json(*a)
    end

    def self.generate_urn(core, id)
      core.get_urn + TOPIC_IDENTIFIER + id
    end

    def get_truncated_id
      @id[@id.index(TOPIC_IDENTIFIER) + TOPIC_IDENTIFIER.length]
    end

	end
end