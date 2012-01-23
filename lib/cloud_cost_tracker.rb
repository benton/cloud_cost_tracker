require 'active_record'
require 'logger'

# Load all ruby files from 'cloud_cost_tracker' directory
Dir[File.join(File.dirname(__FILE__), "cloud_cost_tracker/**/*.rb")].each {|f| require f}

module CloudCostTracker

  # The default polling interval in seconds
  # This. can be overriden when a CloudCostTracker::Tracker is created, either
  # in the +accounts+ definitions, or in the +options+ parameter
  DEFAULT_POLLING_TIME = 300   # by default, poll all accounts every 5 minutes

  # Returns a slightly-modified version of the default Ruby Logger
  def self.default_logger
    logger = ::Logger.new(STDOUT)
    logger.sev_threshold = Logger::INFO
    logger.formatter = proc {|lvl, time, prog, msg|
      "#{lvl} #{time.strftime '%Y-%m-%d %H:%M:%S %Z'}: #{msg}\n"
    }
    logger
  end

end
