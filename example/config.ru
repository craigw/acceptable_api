require 'acceptable_api'
require './example'

require 'json'
require 'builder'

app = AcceptableApi::Builder.new

app.register Sandwich => 'text/plain' do |sandwich|
  s = []
  s << sandwich.name
  s << sandwich.fillings.sort.join(',')
  s << sandwich.bread
  s << sandwich.made_at.iso8601
  s.join "\n"
end

app.register Sandwich => 'application/vnd.acme.sandwich-v1+xml' do |sandwich|
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

app.register Sandwich => 'application/json' do |sandwich|
  JSON.generate :id => sandwich.id
end

app.register Sandwich => 'application/vnd.acme.sandwich-v1+json' do |sandwich|
  JSON.generate :name => sandwich.name, :fillings => sandwich.fillings,
    :bread => sandwich.bread
end

app.expose 'SandwichResource#show_sandwich', at: '/sandwiches/:id',
                                             via: 'get'

run app.to_app
