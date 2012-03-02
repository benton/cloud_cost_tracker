DEFAULT_CONFIG_FILE = File.expand_path('../../../config/database.yml', __FILE__)
require 'active_record'

namespace :db do
  namespace :migrate do

    desc "Conforms the schema of the tracker database. "+
      "Target specific version with VERSION=x"
    task :tracker => :db_connect do
      ActiveRecord::Migrator.migrate(
      File.join(Gem.loaded_specs['cloud_cost_tracker'].full_gem_path,
        'db', 'migrate'), ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      )
    end

    task :db_connect do
      config_file = DEFAULT_CONFIG_FILE
      config_file = './config/database.yml' if File.exists? './config/database.yml'
      config_file = ENV['DB_CONFIG_FILE'] if ENV['DB_CONFIG_FILE']
      ActiveRecord::Base.establish_connection(
        YAML::load(File.open(config_file))[ENV['RACK_ENV'] || 'development'])
    end

  end
end
