# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guise/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eduardo Gutierrez"]
  gem.description   = %q{ Flexible roles system for any context }
  gem.summary       = %q{
                        Guise manages roles without having to define them in as records in the
                        database. Also works as multi-table inheritance.
                      }
  gem.homepage      = "https://github.com/ecbypi/guise"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "guise"
  gem.require_paths = ["lib"]
  gem.version       = Guise::VERSION
  gem.license       = 'MIT'

  gem.required_ruby_version = ">= 2.3.0"

  gem.add_dependency "activerecord", ">= 4.2"
  gem.add_dependency "activesupport", ">= 4.2"
  gem.add_development_dependency "appraisal", ">= 1.0"
  gem.add_development_dependency "byebug", "~> 10.0"
  gem.add_development_dependency "pry", "~> 0.9"
  gem.add_development_dependency "rake", "~> 12.3"
  gem.add_development_dependency "redcarpet", "~> 3.2"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "sqlite3", "~> 1.3"
  gem.add_development_dependency "yard", ">= 0.9.20"
end
