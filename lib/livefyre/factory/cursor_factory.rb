require 'livefyre/entity/timeline_cursor'

module Livefyre
  class CursorFactory
    def self.get_topic_stream_cursor(core, topic, limit)
      resource = "#{topic.id}:topicStream"
      TimelineCursor.new(core, resource, limit)
    end

    def self.get_personal_stream_cursor(network, user, limit)
      resource = "#{network.get_user_urn(user)}:personalStream"
      TimelineCursor.new(network, resource, limit)
    end
  end
end