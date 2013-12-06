# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'my_crawler/version'

Gem::Specification.new do |spec|
  spec.name          = "my_crawler"
  spec.version       = MyCrawler::VERSION
  spec.authors       = ["Roma"]
  spec.email         = ["romaslmd@gmail.com"]
  spec.description   = %q{Market.Yandex.Parser}
  spec.summary       = %q{Parse MY and store in MongoDB}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
