require 'test_helper'

module AcceptableApi
  class AcceptanceTest < Test::Unit::TestCase
    include Rack::Test::Methods

    class Example
      attr_accessor :token
      private :token=, :token

      def initialize token
	self.token = token
      end

      def self.find token
	# Normally this would load the resource from the data store
	new token
      end

      def to_s
	"token #{token}"
      end
    end

    class ExampleResource
      include AcceptableApi::Controller

      def show
	Example.find params[:token]
      end
    end

    def app
      a = AcceptableApi::Builder.new
      a.register Example => 'application/vnd.acceptable-api.example-v1+txt' do |ex|
	'Ducks ' + ex.to_s
      end

      a.register Example => 'application/vnd.acceptable-api.example-v2+txt' do |ex|
	'Chickens ' + ex.to_s
      end

      a.expose 'AcceptableApi::AcceptanceTest::ExampleResource#show', at: '/example/:token', via: 'get'
      a.to_app
    end
  end
end
