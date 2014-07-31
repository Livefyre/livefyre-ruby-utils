require 'livefyre/entity/timeline_cursor'

module Livefyre
  class CursorFactory
    def self.get_topic_stream_cursor(core, topic, limit, date)
      resource = "#{topic.id}:topicStream"
      TimelineCursor.new(core, resource, limit, date)
    end

    def self.get_personal_stream_cursor(network, user, limit, date)
      resource = "#{network.get_user_urn(user)}:personalStream"
      TimelineCursor.new(network, resource, limit, date)
    end
  end
end