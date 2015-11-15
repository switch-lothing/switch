class DefRel
  include Neo4j::ActiveRel

  from_class Person
  to_class Person
  type 'relation'

  property :relation, type: String , default: RelationStatus::Friend.to_s
end