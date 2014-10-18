require 'livefyre/dto/timeline_cursor'

module Livefyre
  class CursorFactory
    def self.get_topic_stream_cursor(core, topic, limit=50, date=Time.new)
      resource = "#{topic.id}:topicStream"
      TimelineCursor.init(core, resource, limit, date)
    end

    def self.get_personal_stream_cursor(network, user, limit=50, date=Time.new)
      resource = "#{network.get_urn_for_user(user)}:personalStream"
      TimelineCursor.init(network, resource, limit, date)
    end
  end
end