# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ehon/version'

Gem::Specification.new do |spec|
  spec.name          = "ehon"
  spec.version       = Ehon::VERSION
  spec.authors       = ["Tomohiro Nishimura"]
  spec.email         = ["tomohiro68@gmail.com"]
  spec.summary       = %q{Ehon is a simple `enum` library.}
  spec.description   = %q{Ehon is a simple `enum` library.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
