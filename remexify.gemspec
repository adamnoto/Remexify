# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'remexify/version'

Gem::Specification.new do |spec|
  spec.name          = "remexify"
  spec.version       = Remexify::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Adam Pahlevi"]
  spec.email         = ["adam.pahlevi@gmail.com"]
  spec.summary       = %q{Simply log any message/error to your database}
  spec.description   = %q{A gem that make your system a log handler as well, by saving any error to your database system}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "railties", ">= 3.2.6", "< 5"
  spec.add_development_dependency "gem_config"
  spec.add_runtime_dependency "gem_config"
end
