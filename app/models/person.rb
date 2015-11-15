class Person
  include Neo4j::ActiveNode
  include ClassyEnum::ActiveRecord

  property :auth_id, type: String
  property :nickname, type: String
  property :phone_number, type: String
  property :switch_status, type: String
  property :location_x, type: Float
  property :location_y, type: Float

  property :created_at
  property :updated_at

  #relation
  has_many :in, :histories, model_class: History, rel_class: RequestDirection
  has_many :in, :current_requests, model_class: CurrentRequest, rel_class: RequestDirection
  has_many :both, :friends, model_class: Person, rel_class: DefRel

  #validate

  def make_friend_relation_using_phone_number(friend_phone_number)
    friend = Person.find_by(phone_number: friend_phone_number)

    if not friend.nil?
      DefRel.create(from_node: self, to_node:friend, relation: RelationStatus::Friend)
    else

    end
  end
end