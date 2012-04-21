require 'ostruct'
require 'json'
require 'builder'

# One of the resources we're working with.
# For simplicity I'm faking it out using OpenStruct.
class Sandwich < OpenStruct
  # Look up a Sandwich by ID
  def self.find id
    new :fillings => %w(jam avacado anchovies), :bread => "brown",
      :made_at => Time.now, :id => id, :name => "Bleaugh"
  end
end

AcceptableApi.register Sandwich, 'application/json' do |sandwich, request|
  JSON.generate :id => sandwich.id
end

AcceptableApi.register Sandwich, 'application/vnd.acme.sandwich-v1+json' do |sandwich, request|
  JSON.generate :name => sandwich.name, :fillings => sandwich.fillings,
    :bread => sandwich.bread
end

AcceptableApi.register Sandwich, 'application/vnd.acme.sandwich-v1+xml' do |sandwich, request|
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

class Example < AcceptableApi::Controller
  get '/sandwiches/:id' do
    Sandwich.find params[:id]
  end
end
