module Livefyre
  class SiteValidator
    def self.validate(data)
      reason = ''

      reason += '\n Id is null or blank.' if data.id.to_s.empty?
      reason += '\n Key is null or blank.' if data.key.to_s.empty?

      raise ArgumentError, "Problems with your site input: #{reason}" if reason.length > 0

      data
    end
  end
end