module API
  class Base < Grape::API
    error_formatter :json, API::ErrorFormatter
    formatter :json, Grape::Formatter::Jbuilder

    cascade false   # preventing downstream error handlers

    ## Handle StandardError
    rescue_from Neo4j::ActiveNode::Labels::RecordNotFound do |e|
      error_response(message: {code: 404, contents: 'Resource not found'}, status: 404)
    end

    rescue_from :all do |e|
      error_response(message: {contents: "#{e.class.name}  #{e.message}"})
    end
    
    mount API::V1::Base
    mount API::V1::PeopleApi
  end
end
