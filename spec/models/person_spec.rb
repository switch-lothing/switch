require "rails_helper"


RSpec.describe Person, :type => :model do

  context '생성시'do
    it 'person객체를 생성하고 저장된다 ' do
      person = Person.create()
      expect(person).to be_persisted
    end

    it 'person객체간의 친구 관계를 맺을 수 있다.' do
      person = Person.create(nickname: 'me')
      friend1 = Person.create(nickname: 'friend')

      DefRel.create(from_node:person, to_node:friend1, relation: RelationStatus::Friend)

      expect(person.friends.first).to eq(friend1)
    end
  end

  context '친구 관계 생성시' do
    it '전화번호를 기반으로 친구관계를 생성할 수 있다. ' do
      friend_phone_number = '000-000-0000'
      person = Person.create(nickname: 'me')
      friend1 = Person.create(nickname: 'friend', phone_number: friend_phone_number)

      person.make_friend_relation_using_phone_number(friend_phone_number)
      expect(person.friends.first.id).to eq(friend1.id)

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

  context '전화번호 기반으로 사람 조회 시' do
    before do
      Person.create(auth_id: '0001', nickname: 'person1', phone_number: '000-000-0001')
      Person.create(auth_id: '0002', nickname: 'person2', phone_number: '000-000-0002')
      Person.create(auth_id: '0003', nickname: 'person3', phone_number: '000-000-0003')
      Person.create(auth_id: '0004', nickname: 'person4', phone_number: '000-000-0004')
    end

    it 'find_by_phone_numbers함수는 전화번호를 받아서 존재하는 사람의 목록을 리턴한다' do
      phone_numbers = '000-000-0001, 000-000-0002, 000-000-0003, 000-000-0004, 000-000-0005'
      expect(Person.find_by_phone_numbers(phone_numbers).count).to eq(4)
    end
  end

  context '조회시' do
    it '나와 친구관계인 person 객체들을 가져올수 있다 ' do
      person = Person.create(nickname: 'me')
      Person.create(nickname: 'friend', phone_number: '0000')
      Person.create(nickname: 'friend', phone_number: '1111')

      person.make_friend_relation_using_phone_number('0000')
      person.make_friend_relation_using_phone_number('1111')

      expect(person.friends.size).to eq(2)
    end
  end

  it 'make_in_query test' do
    phone_numbers = '010-0000-0000,010-1111-1111'
    phone_numbers_white_space = ' 010-0000-0000, 010-1111-1111 '
    result1 = Person.make_in_query(phone_numbers)
    result2 = Person.make_in_query(phone_numbers_white_space)

    expect(result1).to eq("'010-0000-0000','010-1111-1111'")
    expect(result2).to eq("'010-0000-0000','010-1111-1111'")
  end
end
