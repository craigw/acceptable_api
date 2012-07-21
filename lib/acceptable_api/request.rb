module AcceptableApi
  class Request
    attr_accessor :request
    private :request=, :request

    def initialize rack_request
      self.request = rack_request
    end

    def respond_with resource
      accepts = Accepts.new request.env
      mappers = Mapper.for(resource.class).to(accepts)
      mapper = mappers[0]
      code, headers, body = mapper.execute resource, self
      headers["Content-Length"] = body.bytesize.to_s
      [ code, headers, body ]
    end

    def uri
      request.url
    end
  end
end
