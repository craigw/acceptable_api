# -*- encoding: utf-8 -*-
require File.expand_path('../lib/acceptable_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Craig R Webster"]
  gem.email         = ["craig@barkingiguana.com"]
  gem.description   = %q{HTTP lets clients sned an Accept header. We should probably use that to accept more than the bog-standard mime-types.}
  gem.summary       = %q{Build an Acceptable API}
  gem.homepage      = "http://barkingiguana.com/2011/12/05/principles-of-service-design-program-to-an-interface/"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "acceptable_api"
  gem.require_paths = ["lib"]
  gem.version       = AcceptableApi::VERSION
  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'rack-accept'
  gem.add_runtime_dependency 'rack-accept-header-updater'
  gem.add_runtime_dependency 'sinatra'
end
