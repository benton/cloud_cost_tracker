module FogCostTracker

  # Tracks a single Fog account in an ActiveRecord database
  class AccountTracker
    require 'logger'
    require 'fog'

    attr_reader :name, :account, :log

    # Creates an object for tracking a single Fog account
    #
    # ==== Attributes
    #
    # * +account_name+ - a human-readable name for the account (String)
    # * +account+ - a Hash of account information (see accounts.yml.example)
    # * +options+ - Hash of optional parameters
    #
    # ==== Options
    #
    # * +:delay+ - Default time between polling of accounts
    # * +:log+ - a Ruby Logger-compatible object
    def initialize(account_name, account, options={})
      @name     = account_name
      @account  = account
      @log      = options[:logger] || FogCostTracker.default_logger
      @delay    = options[:delay]  || account[:polling_time] ||
                              FogCostTracker::DEFAULT_POLLING_TIME
      @log.debug "Creating tracker for account #{@name}."
      create_resource_trackers
    end

    # Creates and returns an Array of ResourceTracker objects -
    # one for each resource type associated with this account's service
    def create_resource_trackers
      @resource_trackers = connection.collections.map do |type|
        FogCostTracker::ResourceTracker.new(self, type.to_s)
      end
    end

    # Starts a background thread, which updates all @resource_trackers
    def start
      if not running?
      @log.debug "Starting tracking for account #{@name}..."
        @timer = Thread.new do
          while true do
            @log.info "Polling account #{@name}..."
            @resource_trackers.each {|tracker| tracker.update}
            sleep @delay
          end
        end
      else
        @log.info "Already tracking account #{@name}"
      end
    end

    # Stops all the @resource_trackers
    def stop
      if running?
        @log.info "Stopping tracker for #{name}..."
        @timer.kill
        @timer = nil
      else
        @log.info "Tracking already stopped for account #{@name}"
      end
    end

    # Returns true or false depending on whether this tracker is polling
    def running? ; @timer != nil end

    # Returns a Fog::Connection object to this account's Fog service
    def connection
      creds = @account[:credentials].collect {|k, v| ":#{k} => '#{v}'"}
      ruby_expr = %W{
        ::Fog::#{@account[:service]}.new(
          :provider => '#{@account[:provider]}',
          #{creds.join ', '} )
      }.join ' '
      if not @fog_service
        @log.info "Creating connection to #{@account[:provider]}/"+
          "#{@account[:service]} for #{name}"
        @log.debug "About to eval expression: #{ruby_expr}"
        @fog_service ||= eval(ruby_expr)
      end
      @fog_service
    end
  end
end
