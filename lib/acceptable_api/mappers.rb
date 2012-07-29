module AcceptableApi
  class Mappers
    attr_accessor :mappers
    private :mappers=, :mappers

    def initialize mappers = []
      self.mappers = mappers
    end

    def << mapper
      mappers << mapper
    end

    def from what
      Mappers.new mappers.select { |m| m.from? what }
    end

    def to accepts
      acceptable_mime_types = accepts.order mime_types
      mapper = acceptable_mime_types.map { |mt|
	mappers.detect { |m| m.to? mt }
      }[0]
      return mapper unless mapper.nil?
      MissingMapper.instance
    end

    def mime_types
      mappers.map { |m| m.to }.sort.uniq
    end

    def each &block
      mappers.each &block
    end
    include Enumerable
  end
end
