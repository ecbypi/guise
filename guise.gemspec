# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guise/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eduardo Gutierrez"]
  gem.email         = ["edd_d@mit.edu"]
  gem.description   = %q{ Multiple inheritance STI }
  gem.summary       = %q{
                        Guise provides methods to setup single table
                        inheritance with multiple inheritances possible.
                      }
  gem.homepage      = "https://github.com/ecbypi/guise"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "guise"
  gem.require_paths = ["lib"]
  gem.version       = Guise::VERSION

  gem.add_dependency "activerecord", "~> 3.1"
  gem.add_dependency "activesupport", "~> 3.1"
  gem.add_development_dependency "rspec", "~> 2.9"
  gem.add_development_dependency "sqlite3", "~> 1.3.3"
  gem.add_development_dependency "factory_girl", "~> 3.2"
  gem.add_development_dependency "shoulda-matchers", "~> 1.1"
end
