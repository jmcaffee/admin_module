# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'admin_module/version'

Gem::Specification.new do |spec|
  spec.name          = "admin_module"
  spec.version       = AdminModule::VERSION
  spec.authors       = ["Jeff McAffee"]
  spec.email         = ["jeff@ktechsystems.com"]
  spec.description   = %q{Command line interface for Admin Module}
  spec.summary       = %q{Admin Module CLI}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber", "~> 1.3.9"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  #spec.add_development_dependency "pry-byebug", "~> 1.3.3"
  spec.add_development_dependency "pry", "~> 0.10"

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "page-object"
  spec.add_runtime_dependency "thor"
end
