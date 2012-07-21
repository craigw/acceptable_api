module AcceptableApi
  class MissingMapper
    include Singleton

    def mime_type
      'application/javascript'
    end

    def execute resource, request
      # set the response to "no acceptable representation available"
      mappers = Mapper.for resource.class
      body = {
	:links => mappers.mime_types.map do |mime_type|
	  { :rel => "alternative", :type => mime_type, :uri => request.uri }
	end
      }
      [ 406, { 'Content-Type' => 'application/javascript' }, JSON.pretty_generate(body) ]
    end
  end
end
