class RequestDirection
  include Neo4j::ActiveRel

  property :direction, type: Direction
end