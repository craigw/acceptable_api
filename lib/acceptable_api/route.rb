module AcceptableApi
  class Route
    [ :controller_action, :constraints ].each do |a|
      attr_accessor a
      private "#{a}=", a
    end

    def initialize constraints, controller_action
      self.constraints = constraints
      self.controller_action = controller_action
    end

    def match? request
      return false unless constraints[:via].upcase == request.request_method
      return false unless path_regex.match request.path
      true
    end

    def path_regex
      named_captures = constraints[:at].gsub /\:([^\/]+)/, '(?<\1>[^\/]+)'
      Regexp.new "^#{named_captures}$"
    end

    def params_from request
      matches = path_regex.match request.path
      matches.names.inject({}) { |a,e|
        a.merge! e.to_sym => matches[e]
        a
      }
    end

    def controller_for_request request
      controller_class.new params_from(request), controller_method
    end

    def controller_class
      controller_class_name.split(/::/).inject(Object) { |scope, const_name|
        scope.const_get const_name
      }
    end

    def controller_class_name
      controller_action.split(/#/, 2)[0]
    end

    def controller_method
      controller_action.split(/#/, 2)[-1]
    end
  end
end
