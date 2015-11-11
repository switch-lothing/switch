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
  has_many :both, :people, model_class: Person, rel_class: DefRel

  #validate
end