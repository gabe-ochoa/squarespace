# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'squarespace/version'

Gem::Specification.new do |spec|
  spec.name          = "squarespace"
  spec.version       = Squarespace::VERSION
  spec.summary       = %q{Ruby interface to the Squarespace API}
  spec.description   = %q{Ruby interface to the SquareSpace API}
  spec.homepage      = "https://github.com/gabe-ochoa/squarespace"
  spec.author        = 'Gabe Ochoa'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop"

  spec.add_dependency "faraday"
  spec.add_dependency "json"
end
