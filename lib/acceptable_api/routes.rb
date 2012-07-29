module AcceptableApi
  class Routes
    attr_accessor :routes
    private :routes=, :routes

    def initialize routes = []
      self.routes = routes
    end

    def << route
      routes << route
    end

    def for request
      route = routes.detect { |m| m.match? request }
      return MissingRoute.instance unless route
      route
    end
  end
end
