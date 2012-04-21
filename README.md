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

See `example/example.rb` for an example

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
