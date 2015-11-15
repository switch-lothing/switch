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

    it '전화번호를 기반으로 친구관계를 생성할 수 있다. ' do
      friend_phone_number = '000-000-0000'
      person = Person.create(nickname: 'me')
      friend1 = Person.create(nickname: 'friend', phone_number: friend_phone_number)
      
      person.make_friend_relation_using_phone_number(friend_phone_number)
      expect(person.friends.first.id).to eq(friend1.id)

    end

    it '여러개의 전화번호를 받아서 여러명과 친구관계를 맺을 수 있다' do

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
end
