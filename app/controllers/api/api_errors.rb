module API
  class ApiErrors < StandardError; end
  class NotLogInError < ApiErrors; end
  class AlreadyLogInError < ApiErrors; end
end
