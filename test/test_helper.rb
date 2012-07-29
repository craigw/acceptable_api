require 'test/unit'
require 'rack/test'
require 'acceptable_api'

Test::Unit::TestCase.class_eval do
  def self.test name, &block
    define_method "test #{name}", &block
  end
end
