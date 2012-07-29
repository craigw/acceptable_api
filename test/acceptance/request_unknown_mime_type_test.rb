# We can't generate an entity body that's acceptable for the client.
# http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.7
class RequestUnknowntMimeTypeTest < AcceptableApi::AcceptanceTest
  test "the correct status code is returned" do
    header 'Accept', 'application/pdf'
    get '/example/123'
    assert_equal 406, last_response.status
  end

  test "a JSON list of alternatives is returned" do
    header 'Accept', 'application/pdf'
    get '/example/123'
    assert_equal 'application/json', last_response.header['Content-Type']
    json = JSON.parse last_response.body
    links = json["links"]
    assert_equal links.size, 2, "I expected only two links"
    v1 = links.detect { |l| l["Content-Type"] == "application/vnd.acceptable-api.example-v1+txt" }
    assert_not_nil v1, "Expected a link with Content-Type 'application/vnd.acceptable-api.example-v1+txt'"
    assert_equal last_request.url, v1['uri']
    assert_equal 'GET', v1['method']
    assert_equal 'alternative', v1['rel']

    v2 = links.detect { |l| l["Content-Type"] == "application/vnd.acceptable-api.example-v2+txt" }
    assert_not_nil v2, "Expected a link with Content-Type 'application/vnd.acceptable-api.example-v2+txt'"
    assert_equal last_request.url, v2['uri']
    assert_equal 'GET', v2['method']
    assert_equal 'alternative', v2['rel']
  end
end
