require 'livefyre/api/personalized_stream'

module Livefyre
	class TimelineCursor
    attr_reader :core, :resource, :next, :previous
    attr_accessor :limit, :date

    def initialize(core, resource, limit, date)
      @core = core
      @resource = resource
      @limit = limit
      @next = false
      @previous = false
      
      @cursor_time = date.utc.iso8601(3)
    end

    def next(limit=@limit)
      data = PersonalizedStream::get_timeline_stream(@core, @resource, limit, nil, @cursor_time)
      cursor = data['meta']['cursor']

      @next = cursor['hasNext']
      @previous = cursor['next'] != nil
      @cursor_time = cursor['next']

      data
    end

    def previous(limit=@limit)
      data = PersonalizedStream::get_timeline_stream(@core, @resource, limit, @cursor_time, nil)
      cursor = data['meta']['cursor']

      @previous = cursor['hasPrev']
      @next = cursor['prev'] != nil
      @cursor_time = cursor['prev']

      data
    end
    
    def set_cursor_time(time)
      @cursor_time = time.utc.iso8601(3)
    end
	end
end