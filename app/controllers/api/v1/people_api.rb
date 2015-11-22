
module API
  module V1
    class PeopleApi < Grape::API
      version 'v1'
      format :json

      rescue_from API::ApiErrors do |e|
        value = eval(e.message)
        error_response({message: {contents: value[:message], code: value[:status]},status: value[:status]})
      end

      #signup
      params do
        requires :auth_id, type: String
        requires :nickname, type: String
        requires :phone_number, type: String
      end
      post '/signup' do
        auth_id = params[:auth_id]
        nickname = params[:nickname]
        phone_number = params[:phone_number]

        Person.create(auth_id: auth_id, nickname: nickname, phone_number: phone_number)
      end

      #login
      params do
        requires :auth_id, type: String
      end
      post '/login' do
        auth_id = params[:auth_id]
        raise API::AlreadyLogInError.new({message: 'already login', status: 400}) unless cookies[:user_id].nil?
        @current_use = Person.find_by(auth_id: auth_id)

        cookies[:user_id] = @current_use.id
      end

      #logout
      params do
      end
      post '/logout' do
        raise API::NotLogInError.new({message: 'please login', status: 404}) if cookies[:user_id].nil?
        cookies.delete(:user_id)
      end

      #add friend using phone number
      params do
        requires :phone_number, type: String
      end
      post '/friend/add' do
        friend_phone_number = params[:phone_number]
        current_user_id = cookies[:user_id]
        current_user = Person.find_by(uuid: current_user_id)

        current_user.make_friend_relation_using_phone_number(friend_phone_number)
      end

    end
  end
end