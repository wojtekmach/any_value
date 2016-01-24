# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "any_value/version"

Gem::Specification.new do |spec|
  spec.name          = "any_value"
  spec.version       = AnyValue::VERSION
  spec.authors       = ["Wojtek Mach"]
  spec.email         = ["wojtek@wojtekmach.pl"]

  spec.summary       = %q{Collection of helper methods for testing "shape" of the data}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/wojtekmach/any_value"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
