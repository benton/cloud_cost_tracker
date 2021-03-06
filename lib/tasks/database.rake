require 'active_record'
require 'cloud_cost_tracker'

namespace :db do
  namespace :migrate do

    desc "Conforms the schema of the tracker database. "+
      "VERSION=[20120119000000] RACK_ENV=[development]"
    task :tracker => :db_connect do
      ActiveRecord::Migrator.migrate(
      File.join(Gem.loaded_specs['cloud_cost_tracker'].full_gem_path,
        'db', 'migrate'), ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      )
    end

    task :db_connect do
      config_file = ENV['DB_CONFIG_FILE'] || './config/database.yml'
      puts "Using database config file #{config_file}..."
      config = YAML::load(File.open(config_file))[CloudCostTracker.env]
      puts "Using database #{config['database']}..."
      ActiveRecord::Base.establish_connection(config)
    end

  end
end
