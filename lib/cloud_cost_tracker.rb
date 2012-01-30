require 'active_record'
require 'logger'

# Load all ruby files from 'cloud_cost_tracker' directory
Dir[File.join(File.dirname(__FILE__), "cloud_cost_tracker/**/*.rb")].each {|f| require f}
