$:.unshift File.dirname(__FILE__) + '/../lib'
require 'acceptable_api'
require 'ostruct'
require 'json'
require 'builder'

# One of the resources we're working with
class Document < OpenStruct
end

AcceptableApi.register Document, 'application/vnd.acme.document-v1+xml' do |doc, request|
  xml = Builder::XmlMarkup.new
  xml.document do |d|
    d.content doc.content
  end
end

AcceptableApi.register Document, 'application/vnd.acme.document-v2+xml' do |doc, request|
  xml = Builder::XmlMarkup.new
  xml.document do |d|
    d.content doc.content
    d.tags do |tags|
      doc.tags.each { |tag| tags.tag tag }
    end
  end
end

AcceptableApi.register Document, 'application/vnd.acme.document-v2+json' do |doc, request|
  JSON.generate :id => doc.id, :content => doc.content, :tags => doc.tags
end

AcceptableApi.register Document, 'application/json' do |doc, request|
  JSON.generate :id => doc.id, :content => doc.content
end

class Example < AcceptableApi::Controller
  get '/documents/:id' do
    Document.new :id => params[:id], :content => "Foo bar baz quuz",
      :tags => %w(alpha beta gamma)
  end
end
