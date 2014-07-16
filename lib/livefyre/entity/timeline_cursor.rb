require 'livefyre/api/personalized_streams'

module Livefyre
	class TimelineCursor
    def initialize(core, resource, limit)
      @core = core
      @resource = resource
      @limit = limit
      @next = false
      @previous = false
      @cursor_time = nil
    end

    def next(limit=@limit)
      data = PersonalizedStreamsClient::get_timeline_stream(@core, @resource, @limit, nil, @cursor_time)
      cursor = data['meta']['cursor']

      @next = cursor['hasNext']
      @previous = cursor['next'] != nil

      @cursor_time = @previous ? cursor['next'] : @cursor_time

      data
    end

    def previous(limit=@limit)
      data = PersonalizedStreamsClient::get_timeline_stream(@core, @resource, @limit, nil, @cursor_time)
      cursor = data['meta']['cursor']

      @previous = cursor['hasPrev']
      @next = cursor['prev'] != nil

      @cursor_time = @next ? cursor['prev'] : @cursor_time

      data
    end
	end
end