module AcceptableApi
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
end
