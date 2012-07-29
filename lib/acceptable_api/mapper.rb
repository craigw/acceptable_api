module AcceptableApi
  class Mapper
    [ :from, :to, :map_block ].each do |a|
      attr_accessor a
      private "#{a}="
    end
    private :map_block

    def missing?
      false
    end

    def initialize from, to, &map_block
      self.from = from
      self.to = to
      self.map_block = map_block
    end

    def from? desired
      from == desired
    end

    def to? desired
      to == desired
    end

    def execute resource, request
      map_block.call resource, request
    end
  end
end
