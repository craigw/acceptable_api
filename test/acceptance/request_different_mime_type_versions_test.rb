require 'acceptance/test_helper'

class RequestDifferentMimeTypeVersionsTest < AcceptableApi::AcceptanceTest
  test "the correct representation is returned" do
    header 'Accept', 'application/vnd.acceptable-api.example-v1+txt'
    get '/example/123'
    assert_equal 'Ducks token 123', last_response.body
    assert_equal 'application/vnd.acceptable-api.example-v1+txt', last_response.headers['Content-Type']

    header 'Accept', 'application/vnd.acceptable-api.example-v2+txt'
    get '/example/123'
    assert_equal 'Chickens token 123', last_response.body
    assert_equal 'application/vnd.acceptable-api.example-v2+txt', last_response.headers['Content-Type']
  end
end
