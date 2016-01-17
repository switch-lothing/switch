
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
        requires :gcm_user_token, type: String
        requires :profile_image, type: String
        requires :thumbnail_image, type: String
      end
      post '/signup' do
        auth_id = params[:auth_id]
        nickname = params[:nickname]
        phone_number = params[:phone_number]
        gcm_user_token = params[:gcm_user_token]
        profile_image = params[:profile_image]
        thumbnail_image = params[:thumbnail_image]

        Person.create(auth_id: auth_id, nickname: nickname, phone_number: phone_number, gcm_user_token: gcm_user_token, profile_image: profile_image,
        thumbnail_image: thumbnail_image)
      end

      #add friend using phone number
      params do
        requires :auth_id, type: String
        requires :phone_number, type: String
      end
      post '/friend/add' do
        friend_phone_number = params[:phone_number]
        current_user_id = params[:auth_id]
        current_user = Person.find_by(auth_id: current_user_id)

        raise API::DoNotExistPersonError.new({message: 'this auth id do not exist', status: 404}) if current_user.nil?
        current_user.make_friend_relation_using_phone_number(friend_phone_number)
      end

      params do
        requires :auth_id, type: String
        requires :phone_numbers, type: String
      end
      post '/friends/add' do
        phone_numbers = params[:phone_numbers]
        current_user_id = params[:auth_id]

        current_user = Person.find_by(auth_id: current_user_id)
        raise API::DoNotExistPersonError.new({message: 'this auth id do not exist', status: 404}) if current_user.nil?
        current_user.make_friends_relation_using_phone_numbers(phone_numbers)
        'success'
      end

      params do
        requires :auth_id, type: String
        requires :phone_numbers, type: String
      end
      post '/friends/candidate', jbuilder: '/api/candidate.json'do
        phone_numbers = params[:phone_numbers]
        current_user_id = params[:auth_id]

        current_user = Person.find_by(auth_id: current_user_id)
        raise API::DoNotExistPersonError.new({message: 'this auth id do not exist', status: 404}) if current_user.nil?
        @candidate = Person.find_by_phone_numbers(phone_numbers)
      end

      #get friends
      params do
        requires :auth_id, type: String
      end
      get '/friends', jbuilder:'/api/friends.json' do
        current_user_id = params[:auth_id]
        current_user = Person.find_by(auth_id: current_user_id)
        raise API::DoNotExistPersonError.new({message: 'this auth id do not exist', status: 404}) if current_user.nil?
        @friends = current_user.friends
      end


      #swich on/off
      params do
        requires :auth_id, type: String
      end
      put '/switch/on' do
        current_user_id = params[:auth_id]
        current_user = Person.find_by(auth_id: current_user_id)
        raise API::DoNotExistPersonError.new({message: 'this auth id do not exist', status: 404}) if current_user.nil?

        current_user.switch_status = SwitchStatus::On
        if current_user.save
          'switch on'
        else
          'fail'
        end
      end

      params do
        requires :auth_id, type: String
      end
      put '/switch/off' do
        current_user_id = params[:auth_id]
        current_user = Person.find_by(auth_id: current_user_id)
        raise API::DoNotExistPersonError.new({message: 'this auth id do not exist', status: 404}) if current_user.nil?

        current_user.switch_status = SwitchStatus::Off
        if current_user.save
          'switch off'
        else
          'fail'
        end
      end
    end
  end
end