Bundler.require # Load all gems and libs

Fog.mock!       # Don't try to connect to the network
module CloudCostTracker
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
end

# Establish ActiveRecord connection
db_conf_file = File.expand_path('../../config/database.yml', __FILE__)
db_config = YAML::load(File.open(db_conf_file))[ENV['RACK_ENV'] || 'development']
puts "Using DB #{db_config['database']}..."
ActiveRecord::Base.establish_connection(db_config)

# Require RSpec support files. Logging is configured there
support_files = Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")]
support_files.sort.each {|f| require f}

# RSpec configuration block
RSpec.configure do |config|
  config.mock_with :rspec   # == Mock Framework
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"
end
