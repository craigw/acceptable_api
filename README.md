# AcceptableApi

Build an acceptable API.

HTTP is pretty darn awesome you guys. Part of HTTP - `Accept` headers -
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

Assume you have a class that you want to expose via a lovely HTTP ReST API:

    # app/models/sandwich.rb
    class Sandwich
      attr_accessor :id
      private :id=

      def initialize id
        self.id = id
        self.bread = "Brown"
        self.fillings = %w(mayo chicken salad)
        self.name = "Chicken Mayo Salad"
        self.made_at = Time.now
      end

      attr_accessor :fillings
      attr_accessor :bread
      attr_accessor :name
      attr_accessor :made_at
    end

You'd declare that you wanted to expose it via the API like this:

    # app/resources/sandwich_resource.rb
    class SandwichResource
      include AcceptableApi::Controller

      def show_sandwich
        # Normally this would be a database lookup but since this is just an
        # example I create a new instance to keep things simple
        Sandwich.new params[:id]
      end
    end

Of course, this needs to be run somehow. I've chosen to do this via Rack. In
`config.ru` do this:

    require 'acceptable_api'
    require 'app/models/sandwich'
    require 'app/resource/sandwich_resource'

    app = AcceptableApi::Builder.new
    app.expose 'SandwichResource#show_sandwich', at: '/sandwiches/:id',
                                                 via: 'get'
    run app.to_app

You can now use `rackup` as normal to launch a web server, and `curl` to access
your API, requesting a plain text representation of sandwich 123:

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
haven't told it how to respond with /any/ representations of sandwiches yet. Do
it like this in `config.ru`, before calling `#to_app`:

    app.register Sandwich => 'application/json' do |sandwich|
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

    app.register Sandwich => 'application/vnd.acme.sandwich-v1+json' do |sandwich|
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

    $ curl -H 'Accept: application/json' -i http://localhost:9292/sandwiches/123
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 12

    {"id":"123"}

See the example directory, `example/`, for a working example.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## TODO

* Still need to add tests and discover how to work with the other HTTP verbs,
  starting with POST, PUT, DELETE and OPTIONS. HEAD could be handy as well but
  it's quite possible that software further up the stack could just strip out
  the GET entity to create a valid HEAD response. As a first scratch I'm
  imagining changing the #expose call to something like:

    app.expose SandwichResource, at: '/sandwiches/:id',
      get: 'show', put: 'update', delete: 'destroy'

* I don't like defining the conversions in`config.ru`. It would be lovely if
  these could be picked up automatically on start-up - but I'd settle for
  something less verbose that I currently have. Possibly a slight adaptation of
  the expose call:

    app.expose Sandwich, at: '/sandwiches/:id',
      get: 'show', put: 'update', delete: 'destroy'

  This could guess we want the use `SandwichResource` as the controller, and it
  could examine `app/views/sandwiches/**/*.rb` for convertors:

    convert Sandwich => 'application/vnd.acme.sandwich-v1+xml' do |sandwich|
      xml = Builder::XmlMarkup.new
      xml.sandwich do |s|
        s.name sandwich.name
        s.bread sandwich.bread
        s.fillings do |f|
          sandwich.fillings.each do |filling|
            f.filling filling
          end
        end
      end
    end

* Need to work out how I should deal with authentication etc. Want to keep
  this clean. A controller should be able to return any of the HTTP statuses
  that makes sense, including 401 / 403.


## Authors

Craig R Webster <craig@barkingiguana.com>


## Licence

Released under the terms of the MIT licence, a copy of which can be found in the
`LICENCE` file distributed with this project.
