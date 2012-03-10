desc "Runs the tracker [LOG_LEVEL=[INFO]]"
task :track do
  Rake::Task["db:migrate:db_connect"].invoke
  require "./lib/cloud_cost_tracker"

  # Setup logging
  log = FogTracker.default_logger(STDOUT)
  log.level = ::Logger.const_get((ENV['LOG_LEVEL'] || 'INFO').to_sym)

  log.info "Loading account information..."
  accounts = YAML.load(File.read './config/accounts.yml')

  log.info "Loading custom coding policies..."
  Dir["./config/policies/*.rb"].each {|f| require f}

  CloudCostTracker::Tracker.new(accounts, {:logger => log}).start
  while true do ; sleep 60 end    # Loop forever

end
