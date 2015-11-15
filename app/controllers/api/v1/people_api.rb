
module API
  module V1
    class PeopleApi < Grape::API
      version 'v1'
      format :json

      get '/test' do
        test = 'aaaaaa'
      end
    end
  end
end