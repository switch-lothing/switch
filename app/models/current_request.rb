class CurrentRequest
  include Neo4j::ActiveNode

  property :status, type: String, default: RequestStatus::Meeting.to_s

  property :created_at
  property :updated_at

  #relation
  has_many :out, :people, model_class: Person, rel_class: RequestDirection
end