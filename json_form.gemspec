# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_form/version'

Gem::Specification.new do |spec|
  spec.name          = "json_form"
  spec.version       = JsonForm::VERSION
  spec.authors       = ["Andrius Chamentauskas"]
  spec.email         = ["andrius@bitlogica.com"]
  spec.summary       = %q{Extended ActiveRecord#from_json method that support nesting associations}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "database_cleaner", "~> 1.3.0" # 1.4.0 has a bug that drops migrations
  spec.add_development_dependency "blueprints_boy"
  spec.add_development_dependency "pg"
  spec.add_dependency "activerecord"
end
