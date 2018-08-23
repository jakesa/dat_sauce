# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dat_sauce/version'

Gem::Specification.new do |spec|
  spec.name          = "dat_sauce"
  spec.version       = DATSauce::VERSION
  spec.authors       = ["jakesa"]
  spec.email         = ["jakes55214@yahoo.com"]
  spec.summary       = 'Test runner for Cucumber that implements parallelization'
  spec.description   = ''
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 2"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard'
  spec.add_dependency 'cucumber', ">= 3.0.0"
  spec.add_dependency 'rest-client', '>= 2.0.0'

end
