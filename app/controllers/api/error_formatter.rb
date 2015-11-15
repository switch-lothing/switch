module API
  module ErrorFormatter
    def self.call message, backtrace, options, env
      {code: message[:code], message: message[:contents]}.to_json
    end
  end
end
