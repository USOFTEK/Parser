# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mycra/version'

Gem::Specification.new do |spec|
  spec.name          = "mycra"
  spec.version       = Mycra::VERSION
  spec.authors       = ["Roma Solomud"]
  spec.email         = ["romaslmd@gmail.com"]
  spec.description   = %q{Market yandex parser}
  spec.summary       = %q{Collect items from market.yandex.ua}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
end
