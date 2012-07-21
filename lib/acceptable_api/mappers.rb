module AcceptableApi
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
end
