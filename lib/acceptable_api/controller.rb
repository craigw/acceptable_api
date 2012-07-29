module AcceptableApi
  module Controller
    attr_accessor :params
    protected :params, :params=

    attr_accessor :action
    protected :action, :action=

    def initialize params, action
      self.params = params
      self.action = action
    end

    def perform_action
      send action
    end
  end
end
