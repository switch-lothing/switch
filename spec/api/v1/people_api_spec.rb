require 'rails_helper'
describe API::V1::PeopleApi , :type => :request do
  context 'POST api/v1/signup' do

    create_param = {
        auth_id: '0000',
        nickname: 'test_nick',
        phone_number: '000-000-0000',
        gcm_user_token: 'gcm_token',
        profile_image: 'profile_image_path',
        thumbnail_image: 'thumnail_image_path'
    }

    it 'person객체가 추가된다. ' do
      post 'api/v1/signup', create_param
      expect(Person.find_by(nickname: 'test_nick').nickname).to eq('test_nick')
      expect(Person.find_by(nickname: 'test_nick').gcm_user_token).to eq('gcm_token')
    end
  end

  context 'PUT /api/v1/user/edit' do

    create_param = {
        auth_id: '0000',
        nickname: 'test_nick',
        phone_number: '000-000-0000',
        gcm_user_token: 'gcm_token',
        profile_image: 'profile_image_path',
        thumbnail_image: 'thumnail_image_path'
    }

    change_param = {
        auth_id: '0000',
        nickname: 'change_nick',
        phone_number: '000-000-0001',
        gcm_user_token: 'gcm_token_change',
        profile_image: 'profile_image_path_change',
        thumbnail_image: 'thumnail_image_path_change'
    }

    do_not_exist_auth_id_params = {
        auth_id: 'do_not_exist',
        nickname: 'test_nick',
        phone_number: '000-000-0000',
        gcm_user_token: 'gcm_token',
        profile_image: 'profile_image_path',
        thumbnail_image: 'thumnail_image_path'
    }
    before do
      Person.create(create_param)
    end

    it '회원의 정보를 수정할 수 있다.' do
      user = Person.find_by(auth_id: '0000')
      expect(user.nickname).to eq('test_nick')

      put 'api/v1/user/edit', change_param
      user = Person.find_by(auth_id: '0000')

      expect(response).to have_http_status(200)
      expect(user.nickname).to eq('change_nick')
      expect(user.profile_image).to eq('profile_image_path_change')
    end

    it '회원이 존재하지 않으면 404에러를 발생한다.' do
      put 'api/v1/user/edit', do_not_exist_auth_id_params
      expect(response).to have_http_status(404)
    end
  end

  context 'GET api/v1/friends' do
    request_param = {
        auth_id: '0000'
    }

    do_not_exist_auth_id_param = {
        auth_id: 'do not exist'
    }

    before do
      me = Person.create(auth_id: '0000', nickname: 'me', phone_number: '000-000-0000')
      friends_phone_numbers = ''
      (1..3).each do |i|
        Person.create(auth_id: "000#{i}", nickname: "friend#{i}", phone_number: "000-000-000#{i}")
        friends_phone_numbers << "000-000-000#{i},"
      end

      me.make_friends_relation_using_phone_numbers(friends_phone_numbers)
    end

    it '친구의 목록을 불러올 수 있다.' do
      get 'api/v1/friends', request_param
      result = JSON.parse(response.body)
      expect(result.count).to eq(3)
    end

    it 'auth_id가 존재하지 않을시 404에러를 발생한다' do
      get 'api/v1/friends', do_not_exist_auth_id_param
      expect(response).to have_http_status(404)
    end
  end

  context 'POST api/v1/friend/add' do
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
    add_friends_param = {
        auth_id: '0000',
        phone_numbers: '000-000-0001,000-000-0002,000-000-0003'
    }

    do_not_exist_auth_id_param = {
        auth_id: 'do not exist',
        phone_numbers: '111-111-1111'
    }

    before do
      Person.create(auth_id: '0000', nickname: 'me', phone_number: '000-000-0000')
      Person.create(auth_id: '0001', nickname: 'friend1', phone_number: '000-000-0001')
      Person.create(auth_id: '0002', nickname: 'friend2', phone_number: '000-000-0002')
      Person.create(auth_id: '0003', nickname: 'friend3', phone_number: '000-000-0003')
    end

    it '여러개의 전화번호를 받아서 친구로 추가 할 수 있다.' do
      post 'api/v1/friends/add', add_friends_param
      expect(Person.find_by(auth_id: '0000').friends.count).to eq(3)
    end

    it '존재하지 않는 auth_id를 입력하면 404에러를 바랭한다' do
      post 'api/v1/friends/add', do_not_exist_auth_id_param
      expect(response).to have_http_status(404)
    end
  end

  context 'POST api/v1/friends/candidate' do
    candidate_params = {
        auth_id: '0000',
        phone_numbers: '000-000-0001,000-000-0002,000-000-0003,000-000-0004,000-000-0004'
    }

    do_not_exist_auth_id_param = {
        auth_id: 'do not exist',
        phone_numbers: '111-111-1111'
    }

    before do
      Person.create(auth_id: '0000', nickname: 'me', phone_number: '000-000-0000')
      Person.create(auth_id: '0001', nickname: 'friend1', phone_number: '000-000-0001')
      Person.create(auth_id: '0002', nickname: 'friend2', phone_number: '000-000-0002')
      Person.create(auth_id: '0003', nickname: 'friend3', phone_number: '000-000-0003')
    end

    it '존재하는 사람들의 목록을 확인할 수 있다' do
      post 'api/v1/friends/candidate', candidate_params

      result = JSON.parse(response.body)
      expect(result.count).to eq(3)
    end

    it 'auth_id 가 존재하지 않을시 404에러를 발생한다' do
      post 'api/v1/friends/candidate', do_not_exist_auth_id_param
      expect(response).to have_http_status(404)
    end
  end

  context 'PUT api/v1/switch' do
    request_params = {
        auth_id: '0000'
    }

    do_not_exist_auth_id_param = {
        auth_id: 'do not exist',
    }

    before do
      Person.create(auth_id: '0000', nickname: 'test_nickname', phone_number: '000-000-0000')
    end

    it 'switch/on 요청시 auth_id가 존재하지 않으면 404에러를 발생한다' do
      put 'api/v1/switch/on', do_not_exist_auth_id_param
      expect(response).to have_http_status(404)
    end

    it 'switch/on 요청시 auth_id를 가진 사용자의 switch status를 on으로 저장한다' do
      put 'api/v1/switch/on', request_params
      person = Person.find_by(auth_id: '0000')
      expect(person.switch_status).to eq('SwitchStatus::On')
    end

    it 'switch/off 요청시 auth_id가 존재하지 않으면 404에러를 발생한다' do
      put 'api/v1/switch/off', do_not_exist_auth_id_param
      expect(response).to have_http_status(404)
    end

    it 'switch/off 요청시 auth_id를 가진 사용자의 switch status를 on으로 저장한다' do
      put 'api/v1/switch/off', request_params
      person = Person.find_by(auth_id: '0000')
      expect(person.switch_status).to eq('SwitchStatus::Off')
    end
  end
end

