module AcceptableApi
  class Controller < Sinatra::Base
    use Rack::AcceptHeaderUpdater

    def self.get path, &block
      super path do
	response = Response.new :params => params
	resource = response.instance_eval &block
	api = Request.new request
	s, h, body = api.respond_with resource
	status s
	headers h
	body
      end
    end
  end
end
