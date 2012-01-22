module CloudCostTracker

  # Tracks one or more Fog accounts in an ActiveRecord database
  class Tracker
    require 'fog_tracker'

    # Creates an object for tracking Fog accounts
    #
    # ==== Attributes
    #
    # * +accounts+ - a Hash of account information (see accounts.yml.example)
    # * +options+ - Hash of optional parameters
    #
    # ==== Options
    #
    # * +:delay+ - Time between polling of accounts. Overrides per-account value
    # * +:log+ - a Ruby Logger-compatible object
    def initialize(accounts = {}, options={})
      @accounts = accounts
      @delay    = options[:delay]
      @log      = options[:logger] || CloudCostTracker.default_logger
      @tracker = FogTracker::Tracker.new(
        @accounts, {:delay => @delay, :logger => @log}
      )
    end

    # Invokes the start method on all the @trackers
    def start
      if not running?
        @tracker.start
        @running = true
      else
        @log.info "Already tracking #{@trackers.keys.count} accounts"
      end
    end

    # Invokes the stop method on all the @trackers
    def stop
      if running?
        @tracker.stop
        @running = false
      else
        @log.info "Tracking already stopped"
      end
    end

    # Returns true or false/nil depending on whether this tracker is polling
    def running? ; @running end

  end
end
