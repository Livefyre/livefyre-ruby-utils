require 'livefyre/api/personalized_stream'
require 'livefyre/model/cursor_data'
require 'livefyre/validator/cursor_validator'

module Livefyre
	class TimelineCursor
    attr_accessor :core, :data

    def initialize(core, data)
      @core = core
      @data = data
    end
    
    def self.init(core, resource, limit, date)
      data = CursorData.new(resource, limit, date)
      TimelineCursor.new(core, CursorValidator::validate(data))
    end

    def next
      data = PersonalizedStream::get_timeline_stream(self, true)
      cursor = data['meta']['cursor']

      @data.next = cursor['hasNext']
      @data.previous = cursor['next'] != nil
      if @data.previous
        @data.cursor_time = cursor['next']
      end

      data
    end

    def previous
      data = PersonalizedStream::get_timeline_stream(self, false)
      cursor = data['meta']['cursor']

      @data.previous = cursor['hasPrev']
      @data.next = cursor['prev'] != nil
      if @data.next
        @data.cursor_time = cursor['prev']
      end

      data
    end
	end
end