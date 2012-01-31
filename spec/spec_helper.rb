Bundler.require # Load all gems and libs

Fog.mock!       # Don't try to connect to the network
module CloudCostTracker
  FAKE_AWS = Fog::Compute.new(
    :provider => 'AWS',
    :aws_access_key_id => 'XXXXXXXXXXXXXXXXXXXX',
    :aws_secret_access_key => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  )
end

# Establish ActiveRecord connection
db_conf_file = File.expand_path('../../config/database.yml', __FILE__)
puts "Using DB #{db_conf_file}..."
ActiveRecord::Base.establish_connection(YAML::load(File.open(db_conf_file)))

# Require RSpec support files. Logging is configured there
support_files = Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")]
support_files.sort.each {|f| require f}

# RSpec configuration block
RSpec.configure do |config|
  config.mock_with :rspec   # == Mock Framework
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"
end
