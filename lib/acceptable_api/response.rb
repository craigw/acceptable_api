module AcceptableApi
  # This needs to mimic as much of the Sinatra API as we use.
  # Probably we want to set headers and content_type, not sure what else.
  class Response
    attr_accessor :params
    def initialize options = {}
      self.params = options[:params]
    end
  end
end
