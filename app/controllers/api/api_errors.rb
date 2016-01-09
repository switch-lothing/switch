module API
  class ApiErrors < StandardError; end
  class DoNotExistPersonError < ApiErrors; end
  class AlreadyLogInError < ApiErrors; end
end
