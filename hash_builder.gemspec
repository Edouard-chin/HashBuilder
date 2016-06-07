# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash_builder/version'

Gem::Specification.new do |spec|
  spec.name          = "hash_builder"
  spec.version       = HashBuilder::VERSION
  spec.authors       = ["Edouard Chin"]
  spec.email         = ["chin.edouard@gmail.com"]

  spec.summary       = "Define your hash methods in a friendly way"
  spec.description   = "Hash Builder allows you to define methods that returns a hash with a friendly syntax."
  spec.homepage      = "https://github.com/Edouard-chin/Hash-Builder"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
