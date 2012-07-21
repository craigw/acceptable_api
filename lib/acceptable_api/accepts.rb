module AcceptableApi
  class Accepts
    attr_accessor :request
    private :request=, :request

    def initialize env
      self.request = Rack::Accept::Request.new env
    end

    def order mime_types
      ordered = request.media_type.sort_with_qvalues mime_types, false
      ordered.map! { |q, mt| mt }
      ordered
    end
  end
end
