# AcceptableApi

Build an acceptable API.

HTTP is pretty darn awesome you guys. Part of HTTP - the `Accept` header -
allows the clients of our API to tell us what representation they want to work
with. We should probably pay attention to them, hey?

This is expecially important when writing an API when you may need to deal with
several versions of a representation. When a client asks for JSON we don't
really know if they want JSON version 1 or 5 of our representation.

At some point I'll clean up my thoughts on this and write something decent.
Until then, more reading here:

  http://barkingiguana.com/2011/12/05/principles-of-service-design-program-to-an-interface/

If you know better than me, please mail at me and tell me what I did wrong:
craig@barkingiguana.com.


## Installation

Add this line to your application's Gemfile:

    gem 'acceptable_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acceptable_api

## Usage

Assume you have a class that you want to expose via a lovely HTTP API.

    class Sandwich
      def self.find id
        # Look up a Sandwich by ID
      end

      attr_accessor :fillings
      attr_accessor :bread
      attr_accessor :name
      attr_accessor :made_at
    end

You'd declare that you wanted to expose it via the API as `/sandwiches/123` like
this:

    class SandwichApi < AcceptableApi::Controller
      get '/sandwiches/:id' do
        Sandwich.find params[:id]
      end
    end

Of course, this needs to be run somehow. An `AcceptableApi::Controller` can be
used as a Rack application. In `config.ru` do this:

    require 'acceptable_api'
    require 'sandwich_api'

    run SandwichApi

You can now use `rackup` as normal to launch a web server, and `curl` to access
your API, requesting a JSON representation of sandwich 123:

    $ curl  -H 'Accept: application/json' -i http://localhost:9292/sandwiches/123
    HTTP/1.1 406 Not Acceptable
    Content-Type: application/javascript
    Content-Length: 21

    {
      "links": [

      ]
    }

We got a `406 Not Acceptable` response because AcceptableApi doesn't know how to
respond with an `application/json` representation of a Sandwich. That's fair: we
haven't told it how to respond to /any/ representations yet. Do it like this:

    AcceptableApi.register Sandwich, 'application/json' do |sandwich, request|
      JSON.generate :id => sandwich.id
    end

Let's try requesting the resource again:

    $ curl -H 'Accept: application/json' -i http://localhost:9292/sandwiches/123
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 12

    {"id":"123"}

Ace, we got a response, and it's the JSON represenation of the sandwich. What
happens if we ask for a plain text representation?

    $ curl -H 'Accept: text/plain' -i http://localhost:9292/sandwiches/123
    HTTP/1.1 406 Not Acceptable
    Content-Type: application/javascript
    Content-Length: 146

    {
      "links": [
        {
          "rel": "alternative",
          "type": "application/json",
          "uri": "http://localhost:9292/sandwiches/123"
        }
      ]
    }

As expected, this is a `406 Not Acceptable` response, but we take the
opportunity to provide a list of alternative representations that the client may
want to check out. The `application/json` representation is listed with the type
and the URI to request should the client want to do so.

Time passes, and a we decide that our API would be more useful if it returned
the fillings and bread used in the sandwich, and we want to replace the database
ID with the name of the sandwich. We want to continue supporting the old API
because lots of people are using it. We coin a new mime type in the
`application/vnd.*` space, something we really should have done to start with,
which specifies the returned document:

    application/vnd.acme.sandwich-v1+json

    A valid JSON document containing these keys and meanings:

    name:: the name of the sandwich
    fillings:: an array of fillings in the sandwich
    bread:: the type of bread used in the sandwich

And we register the type with AcceptableApi:

    AcceptableApi.register Sandwich, 'application/vnd.acme.sandwich-v1+json' do |sandwich, request|
      JSON.generate :name => sandwich.name, :fillings => sandwich.fillings,
        :bread => sandwich.bread
    end

And we make the request:

    $  curl -H 'Accept: application/vnd.acme.sandwich-v1+json' -i http://localhost:9292/sandwiches/123
    HTTP/1.1 200 OK
    Content-Type: application/vnd.acme.sandwich-v1+json
    Content-Length: 75

    {"name":"Bleaugh","fillings":["jam","avacado","anchovies"],"bread":"brown"}

Making a request for the normal `application/json` representation still works:

    $ curl -H 'Accept: application/json' -i http://localhost:9292/sandwiches/123HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 12

    {"id":"123"}

See `example/example.rb` for a working example.

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
