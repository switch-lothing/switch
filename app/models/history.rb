class History
  include Neo4j::ActiveNode

  property :result, type: String

  property :created_at
  property :updated_at

  #relation
  has_many :out, :people, model_class: Person, rel_class: RequestDirection
end