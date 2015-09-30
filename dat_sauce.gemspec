# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dat_sauce/version'

Gem::Specification.new do |spec|
  spec.name          = "dat_sauce"
  spec.version       = DatSauce::VERSION
  spec.authors       = ["jakesa"]
  spec.email         = ["jakes55214@yahoo.com"]
  spec.summary       = 'Ruby wrapper for parallel and distributed Cucumber tests on SauceLabs'
  spec.description   = ''
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_dependency 'cucumber', '1.3.17'
  spec.add_dependency 'ruby-progressbar'
  spec.add_dependency 'sauce'
  spec.add_dependency 'sauce-connect'

end
