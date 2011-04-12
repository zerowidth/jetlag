# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jetlag/version"

Gem::Specification.new do |s|
  s.name        = "jetlag"
  s.version     = Jetlag::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nathan Witmer"]
  s.email       = ["nwitmer@gmail.com"]
  s.homepage    = "https://github.com/aniero/jetlag"
  s.summary     = %q{ActiveRecord timezone fixes for non-UTC databases}
  s.description = %q{Patches ActiveRecord to fix timezone issues for non-UTC databases and/or non-UTC default timezones}

  s.add_dependency "activerecord", "~> 2.3.11"

  s.add_development_dependency "sqlite3-ruby"
  s.add_development_dependency "rspec", "~> 1.3.0"
  s.add_development_dependency "rspec-rails", "~> 1.3.0"
  s.add_development_dependency "ZenTest"
  s.add_development_dependency "autotest-growl"
  s.add_development_dependency "autotest-fsevent"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
