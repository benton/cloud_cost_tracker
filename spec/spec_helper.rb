ENV['RACK_ENV'] ||= 'test'
Bundler.require # Load all gems and libs

Fog.mock!       # Don't try to connect to the network

FAKE_ACCOUNT_NAME = 'Fake EC2 Account'
FAKE_ACCOUNT = {
  :name         => FAKE_ACCOUNT_NAME,
  :provider     => 'AWS',
  :service      => 'Compute',
  :delay        => 10,
  :credentials  => {
    :aws_access_key_id => "fake user",
    :aws_secret_access_key => 'fake password'
  },
  :exclude_resources => [
    :spot_requests,   # No Fog mocks for this resource
  ],
}
FAKE_ACCOUNTS = {FAKE_ACCOUNT_NAME => FAKE_ACCOUNT}
FAKE_AWS = Fog::Compute.new(
  :provider => 'AWS',
  :aws_access_key_id => 'XXXXXXXXXXXXXXXXXXXX',
  :aws_secret_access_key => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
)
FAKE_RDS = Fog::AWS::RDS.new(
  :aws_access_key_id => 'XXXXXXXXXXXXXXXXXXXX',
  :aws_secret_access_key => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
)

## Establish ActiveRecord connection and Migrate database
# The following db config files are used, in order of preference:
#   1. ENV['DB_CONFIG_FILE']
#   2. ./config/database.yml
#   3. ./config/database.example.yml
db_conf_file = './config/database.example.yml'
db_conf_file = './config/database.yml' if File.exists? './config/database.yml'
if ENV['DB_CONFIG_FILE']
  db_conf_file = ENV['DB_CONFIG_FILE']
else
  ENV['DB_CONFIG_FILE'] = db_conf_file
end
puts "Reading DB config file #{db_conf_file}..."
db_config = YAML::load(File.open(db_conf_file))[ENV['RACK_ENV'] || 'test']
puts "Using DB #{db_config['database']}..."
ActiveRecord::Base.establish_connection(db_config)
migration_dir = File.expand_path('../../db/migrate', __FILE__)
ActiveRecord::Migrator.migrate migration_dir

# Require RSpec support files. Logging is configured there
support_files = Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")]
support_files.sort.each {|f| require f}

# RSpec configuration block
RSpec.configure do |config|
  config.mock_with :rspec   # == Mock Framework
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"
end
