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
      expect(Person.find_by(nickname: 'test_nick').nickname).to eq('test_nick')
    end
  end

  context 'POST api/v1/friend/add' do
    login_param = {
        auth_id: '0000'
    }

    add_friend_param = {
        auth_id: '0000',
        phone_number: '111-111-1111'
    }

    do_not_exist_auth_id_param = {
        auth_id: 'do not exist',
        phone_number: '111-111-1111'
    }

    before do
      Person.create(auth_id: '0000', nickname: 'me', phone_number: '000-000-0000')
      Person.create(auth_id: '0001', nickname: 'friend', phone_number: '111-111-1111')
    end

    it '전화호를 기반으로 친구가 추가된다.' do
      post 'api/v1/friend/add', add_friend_param

      person = Person.find_by(auth_id: '0000')
      expect(response).to have_http_status(201)
      expect(person.friends.first.nickname).to eq('friend')
    end

    it '존재하지 않는 auth_id를 입력하는 경우 404에러를 발생한다' do
      post 'api/v1/friend/add', do_not_exist_auth_id_param
      expect(response).to have_http_status(404)
    end
  end

  context 'POST api/v1/friends/add' do

  end
end

