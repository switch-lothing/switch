class Person
  include Neo4j::ActiveNode
  include ClassyEnum::ActiveRecord

  property :auth_id, type: String
  property :nickname, type: String
  property :phone_number, type: String
  property :switch_status, type: String, default: SwitchStatus::Off
  property :location_x, type: Float
  property :location_y, type: Float

  property :created_at
  property :updated_at

  #relation
  has_many :in, :histories, model_class: History, rel_class: RequestDirection
  has_many :in, :current_requests, model_class: CurrentRequest, rel_class: RequestDirection
  has_many :both, :friends, model_class: Person, rel_class: DefRel

  #validate

  def self.make_in_query(phone_numbers_string)
    in_query = ""
    phone_numbers = phone_numbers_string.split(',')

    phone_numbers.each do |phone_number|
      phone_number = phone_number.strip
      if in_query.eql? ""
        in_query += "'#{phone_number}'"
      else
        in_query += ",'#{phone_number}'"
      end
    end
    in_query
  end

  def self.find_by_phone_numbers(phone_numbers)
    in_query = Person.make_in_query(phone_numbers)
    Person.query_as(:person).match("person").where("person.phone_number IN [#{in_query}]").pluck(:person)
  end

  def make_friend_relation_using_phone_number(friend_phone_number)
    friend = Person.find_by(phone_number: friend_phone_number)

    if (not friend.nil?) and (not self.friends.include? friend)
      DefRel.create(from_node: self, to_node:friend, relation: RelationStatus::Friend)
    else

    end
  end

  def make_friends_relation_using_phone_numbers(phone_numbers)
    friends = Person.find_by_phone_numbers(phone_numbers)
    friends.each do |friend|
      if not self.friends.include? friend
        DefRel.create(from_node: self, to_node:friend, relation: RelationStatus::Friend)
      end
    end
  end

end