module AcceptableApi
  class MissingMapper
    include Singleton

    def missing?
      true
    end
  end
end
