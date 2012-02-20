# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cloud_cost_tracker/version"

Gem::Specification.new do |s|
  s.name        = "cloud_cost_tracker"
  s.version     = CloudCostTracker::VERSION
  s.authors     = ["Benton Roberts"]
  s.email       = ["benton@bentonroberts.com"]
  s.homepage    = "http://github.com/benton/cloud_cost_tracker"
  s.summary     = %q{Records expenses for cloud computing resources }+
                  %q{in an ActiveRecord database}
  s.description = %q{Periodically polls one or more cloud computing accounts }+
                  %q{using the fog gem, and generates ActiveRecord rows }+
                  %q{representing BillingRecords for each discovered resource.}

  s.rubyforge_project = "cloud_cost_tracker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Runtime dependencies
  s.add_dependency "fog", '>=1.1.2'
  s.add_dependency "fog_tracker", '>=0.3.1'
  s.add_dependency "activerecord", '>=3'

  # Development / Test dependencies
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "ruby_gntp"
  s.add_development_dependency "sqlite3"
end
