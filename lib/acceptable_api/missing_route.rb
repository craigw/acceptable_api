module AcceptableApi
  class MissingRoute
    include Singleton

    def controller_for_request request
      MissingController.instance
    end
  end
end
