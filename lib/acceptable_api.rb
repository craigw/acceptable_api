require 'singleton'
require 'rack/accept'
require 'rack/accept_header_updater'

require 'acceptable_api/accepts.rb'
require 'acceptable_api/controller.rb'
require 'acceptable_api/mapper.rb'
require 'acceptable_api/mappers.rb'
require 'acceptable_api/missing_mapper.rb'
require 'acceptable_api/request.rb'
require 'acceptable_api/response.rb'
require 'acceptable_api/version.rb'

module AcceptableApi
  def self.register klass, mime_type, &map_block
    Mapper.register klass, mime_type, &map_block
  end
end
