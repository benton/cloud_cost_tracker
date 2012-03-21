# Set up bundler
%w{rubygems bundler bundler/gem_tasks}.each {|dep| require dep}
bundles = [:default]
Bundler.setup(:default)
require './lib/cloud_cost_tracker'
case CloudCostTracker.env
when 'development'  then Bundler.setup(:default, :development)
when 'test'         then Bundler.setup(:default, :development, :test)
end

# Load all tasks from 'lib/tasks'
Dir["#{File.dirname(__FILE__)}/lib/tasks/*.rake"].sort.each {|ext| load ext}

desc 'Default: run specs.'
task :default => :spec
