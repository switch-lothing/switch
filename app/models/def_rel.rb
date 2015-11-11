class DefRel
  include Neo4j::ActiveRel

  property :relation, type: String , default: RelationStatus::Friend.to_s
end