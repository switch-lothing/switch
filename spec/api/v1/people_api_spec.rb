require 'rails_helper'
describe API::V1::PeopleApi , :type => :request do
  context 'POST api/v1/signup' do

    create_param ={
        auth_id: '0000',
        nickname: 'test_nick',
        phone_number: '000-000-0000'
    }

    it '회원가입을 할 수 있다. - person객체가 추가된다. ' do
      post 'api/v1/signup', create_param
      expect(Person.all.size).to eq(1)
    end

    it '전화호를 기반으로 친구가 추가된다.' do
      login_param = {
          auth_id: '0000'
      }

      add_friend_param = {
          phone_number: '111-111-1111'
      }

      person = Person.create(auth_id: '0000', nickname: 'me', phone_number: '000-000-0000')
      friend = Person.create(auth_id: '0001', nickname: 'friend', phone_number: '111-111-1111')

      post 'api/v1/login', login_param
      expect(response).to have_http_status(201)

      post 'api/v1/friend/add', add_friend_param
      expect(response).to have_http_status(201)
      expect(person.friends.first.nickname).to eq('friend')

    end
  end
end

