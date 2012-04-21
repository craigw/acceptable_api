require 'sinatra'
require 'singleton'
require 'ostruct'
require 'rack/accept'
require 'rack/accept_header_updater'
require 'json'
require 'builder'

class Document < OpenStruct
end

class MissingMapper
  include Singleton

  def mime_type
    '*/*'
  end

  def execute resource, request
    # set the response to "no acceptable representation available"
    mappers = Mapper.for resource.class
    body = {
      :links => mappers.mime_types.map do |mime_type|
        { :rel => "alternative", :type => mime_type, :uri => request.uri }
      end
    }
    [ 406, { 'Content-Type' => 'application/javascript' }, JSON.pretty_generate(body) ]
  end
end

class Mappers
  attr_accessor :mappers
  private :mappers=, :mappers

  def initialize mappers
    self.mappers = mappers
  end

  def to accepts
    acceptable_mime_types = accepts.order mime_types
    acceptable_mappers = acceptable_mime_types.map { |mt|
      mappers.detect { |m| m.mime_type == mt }
    }
    return acceptable_mappers if acceptable_mappers.any?
    [ MissingMapper.instance ]
  end

  def mime_types
    mappers.map { |m| m.mime_type }.sort.uniq
  end
end

class Mapper
  [ :klass, :mime_type, :map_block ].each do |a|
    attr_accessor a
    private "#{a}="
  end
  private :map_block

  def initialize klass, mime_type, &map_block
    self.klass = klass
    self.mime_type = mime_type
    self.map_block = map_block
  end

  def execute resource, request
    body = map_block.call resource, request
    [ status, headers, body ]
  end

  def status
    200
  end

  def headers
    { 'Content-Type' => mime_type }
  end

  def self.for klass
    klass_mappers = mappers.select { |m| m.klass == klass }
    Mappers.new klass_mappers
  end

  class << self;
    attr_accessor :mappers
    protected :mappers=, :mappers
  end
  self.mappers = []

  def self.register klass, mime_type, &map_block
    mapper = Mapper.new klass, mime_type, &map_block
    self.mappers << mapper
  end
end

Mapper.register Document, 'application/vnd.acme.document-v1+xml' do |doc, request|
  xml = Builder::XmlMarkup.new
  xml.document do |d|
    d.content doc.content
  end
end

Mapper.register Document, 'application/vnd.acme.document-v2+xml' do |doc, request|
  xml = Builder::XmlMarkup.new
  xml.document do |d|
    d.content doc.content
    d.tags do |tags|
      doc.tags.each { |tag| tags.tag tag }
    end
  end
end

Mapper.register Document, 'application/vnd.acme.document-v2+json' do |doc, request|
  JSON.generate :id => doc.id, :content => doc.content, :tags => doc.tags
end

Mapper.register Document, 'application/json' do |doc, request|
  JSON.generate :id => doc.id, :content => doc.content
end

# This needs to mimic as much of the Sinatra API as we use.
# Probably we want to set headers and content_type, not sure what else.
class Response
  attr_accessor :params
  def initialize options = {}
    self.params = options[:params]
  end
end

class Accepts
  attr_accessor :request
  private :request=, :request

  def initialize env
    self.request = Rack::Accept::Request.new env
  end

  def order mime_types
    ordered = request.media_type.sort_with_qvalues mime_types, false
    ordered.map! { |q, mt| mt }
    ordered
  end
end

class Request
  attr_accessor :request
  private :request=, :request

  def initialize rack_request
    self.request = rack_request
  end

  def respond_with resource
    accepts = Accepts.new request.env
    mappers = Mapper.for(resource.class).to(accepts)
    mapper = mappers[0]
    code, headers, body = mapper.execute resource, self
    headers["Content-Length"] = body.bytesize.to_s
    [ code, headers, body ]
  end

  def uri
    request.url
  end
end

class AcceptableApi < Sinatra::Base
  use Rack::AcceptHeaderUpdater

  def self.get path, &block
    super path do
      response = Response.new :params => params
      resource = response.instance_eval &block
      api = Request.new request
      s, h, body = api.respond_with resource
      status s
      headers h
      body
    end
  end
end

class Example < AcceptableApi
  get '/documents/:id' do
    Document.new :id => params[:id], :content => "Foo bar baz quuz",
      :tags => %w(alpha beta gamma)
  end
end
