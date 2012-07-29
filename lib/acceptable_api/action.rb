module AcceptableApi
  class Action
    attr_accessor :route
    private :route=, :route

    attr_accessor :request
    private :request=, :request

    attr_accessor :mappers
    private :mappers=, :mappers

    def initialize route, request, mappers
      self.route = route
      self.request = request
      self.mappers = mappers
    end

    def execute
      resource = controller.perform_action
      resource_mappers = mappers.from resource.class
      mapper = resource_mappers.to acceptable_mime_types
      if mapper.missing?
        body = {
          :links => resource_mappers.mime_types.map do |mime_type|
            { :rel => "alternative", 'Content-Type' => mime_type, :uri => request.url, :method => request.request_method }
          end
        }
        [ 406, { 'Content-Type' => 'application/json' }, [ JSON.pretty_generate(body) ] ]
      else
        body = mapper.execute resource, request
        [ 200, { 'Content-Type' => mapper.to }, [ body ] ]
      end
    end

    def controller
      route.controller_for_request request
    end

    def acceptable_mime_types
      Accepts.new request.env
    end
  end
end
