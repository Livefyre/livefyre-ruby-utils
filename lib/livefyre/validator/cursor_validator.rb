module Livefyre
  class CursorValidator
    def self.validate(data)
      reason = ''

      reason += '\n Resource is null or blank' if data.resource.to_s.empty?
      reason += '\n Limit is null or blank' if data.limit.to_s.empty?
      reason += '\n Cursor time is null or blank' if data.cursor_time.to_s.empty?

      raise ArgumentError, "Problems with your cursor input: #{reason}" if reason.length > 0

      data
    end
  end
end