module AcceptableApi
  class Builder
    attr_accessor :mappers
    protected :mappers=, :mappers

    attr_accessor :routes
    protected :routes=, :routes

    def initialize
      self.mappers = Mappers.new
      self.routes = Routes.new
    end

    def register from_to, &map_block
      from = from_to.keys[0]
      to = from_to.values[0]
      mapper = Mapper.new from, to, &map_block
      self.mappers << mapper
    end

    def expose controller_action, options = {}
      route = Route.new options, controller_action
      self.routes << route
    end

    def to_app
      Application.new mappers, routes
    end
  end
end

