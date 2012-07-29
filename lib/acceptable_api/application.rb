module AcceptableApi
  class Application
    attr_accessor :routes
    protected :routes=, :routes

    attr_accessor :mappers
    protected :mappers=, :mappers

    def initialize mappers, routes
      self.mappers = mappers
      self.routes = routes
    end

    def call env
      request = Rack::Request.new env
      action = action_for request
      action.execute
    end

    def action_for request
      route = routes.for request
      Action.new route, request, mappers
    end
    private :action_for
  end
end
