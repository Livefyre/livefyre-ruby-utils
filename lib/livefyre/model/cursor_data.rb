module Livefyre
  class CursorData
    attr_accessor :resource, :limit, :cursor_time, :next, :previous

    def initialize(resource, limit, start_time)
      @resource = resource
      @limit = limit
      @cursor_time = start_time.utc.iso8601(3)
      @next = false
      @previous = false
    end

    def set_cursor_time(date)
      @cursor_time = date.utc.iso8601(3)
    end
  end
end
