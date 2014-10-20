module Livefyre
  class NetworkValidator
    def self.validate(data)
      reason = ''

      if data.name.to_s.empty?
        reason += '\n Name is null or blank'
      elsif not data.name.end_with?('fyre.co')
        reason += '\n Name should end with \'fyre.co\'.'
      end

      reason += '\n Key is null or blank' if data.key.to_s.empty?

      raise ArgumentError, "Problems with your network input: #{reason}" if reason.length > 0

      data
    end
  end
end