# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exception_notification/td/version'

Gem::Specification.new do |spec|
  spec.name          = "exception_notification-td"
  spec.version       = ExceptionNotification::Td::VERSION
  spec.authors       = ["Uchio KONDO"]
  spec.email         = ["udzura@udzura.jp"]
  spec.summary       = %q{Send exception info to TreasureData}
  spec.description   = %q{Send exception info to TreasureData}
  spec.homepage      = "https://github.com/udzura/exception_notification-td"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "td-logger"
  spec.add_dependency "exception_notification", ">= 3.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "test-unit", ">= 3"
  spec.add_development_dependency "test-unit-rr"
  spec.add_development_dependency "test-unit-power_assert"
  spec.add_development_dependency "rack"
end
