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

    it 'make_in_query test' do
      phone_numbers = '010-0000-0000,010-1111-1111'
      phone_numbers_white_space = ' 010-0000-0000, 010-1111-1111 '
      result1 = Person.make_in_query(phone_numbers)
      result2 = Person.make_in_query(phone_numbers_white_space)

      expect(result1).to eq("'010-0000-0000','010-1111-1111'")
      expect(result2).to eq("'010-0000-0000','010-1111-1111'")
    end

    it '여러개의 전화번호를 기반으로 한번에 친구를 등록한다.' do
      friend1 = Person.create(auth_id: '0001', nickname: 'person1', phone_number: '000-000-0001')
      friend2 = Person.create(auth_id: '0002', nickname: 'person2', phone_number: '000-000-0002')
      friend3 = Person.create(auth_id: '0003', nickname: 'person3', phone_number: '000-000-0003')
      friend4 = Person.create(auth_id: '0004', nickname: 'person4', phone_number: '000-000-0004')

      phone_numbers = '000-000-0002,000-000-0003,000-000-0004'
      friend1.make_friends_relation_using_phone_numbers(phone_numbers)

      expect(friend1.friends).to include(friend2)
      expect(friend1.friends).to include(friend3)
      expect(friend1.friends).to include(friend4)
    end

    it '여러개의 전화번호를 기반으로 친구를 등록할때, 이미 등록한 번호는 등록하지 않는다 ' do
      friend1 = Person.create(auth_id: '0001', nickname: 'person1', phone_number: '000-000-0001')
      friend2 = Person.create(auth_id: '0002', nickname: 'person2', phone_number: '000-000-0002')
      friend3 = Person.create(auth_id: '0003', nickname: 'person3', phone_number: '000-000-0003')
      friend4 = Person.create(auth_id: '0004', nickname: 'person4', phone_number: '000-000-0004')

      phone_numbers1 = '000-000-0002'
      phone_numbers2 = '000-000-0002,000-000-0003,000-000-0004'
      friend1.make_friends_relation_using_phone_numbers(phone_numbers1)

      expect(friend1.friends).to include(friend2)
      expect(friend1.friends.size).to eq(1)

      friend1.make_friends_relation_using_phone_numbers(phone_numbers2)
      expect(friend1.friends).to include(friend3)
      expect(friend1.friends).to include(friend4)
      expect(friend1.friends.size).to eq(3)
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
end

