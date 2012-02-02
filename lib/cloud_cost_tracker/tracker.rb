module CloudCostTracker

  # Tracks the resources in one or more Fog accounts in an ActiveRecord database
  class Tracker

    # each CloudCostTracker is a thin wrapper around it's @tracker,
    require 'fog_tracker'     # which is a FogTracker:Tracker
    extend Forwardable        # most public methods are delegated
    def_delegators :@tracker,:start,:stop,:query,:[],
            :running?,:types_for_account,:logger

    # Creates an object for tracking Fog accounts in an ActiveRecord database
    # @param [Hash] accounts a Hash of account information
    #    (see accounts.yml.example)
    # @param [Hash] options optional additional parameters:
    #  - :delay (Integer) - Default time between polling of accounts
    #  - :error_callback (Proc) - A Method or Proc to call if polling errors occur.
    #    (should take a single Exception as its only required parameter)
    #  - :logger - a Ruby Logger-compatible object
    def initialize(accounts = {}, options={})
      @accounts = accounts
      @delay    = options[:delay]
      @log      = options[:logger] || FogTracker.default_logger
      setup_fog_tracker
      @running  = false
    end

    private

    # Creates a FogTracker::Tracker that calls bill_for_account
    # each time an account is refreshed
    def setup_fog_tracker
      @tracker = FogTracker::Tracker.new(@accounts,
        {:delay => @delay, :logger => @log,
          :callback => Proc.new do |resources|
            bill_for_resources(resources)
          end
        }
      )
    end

    # Generates BillingRecords for all Resources in account named +account_name+
    def bill_for_resources(resources)
      return if resources.empty?
      account_name = resources.first.tracker_account[:name]
      @log.info "Generating cost info for account #{account_name}"
      # keep a Hash of BillingPolicy agents, indexed by resource Class name
      agents = Hash.new
      ((resources.collect {|r| r.class}).uniq).each do |resource_class|
        agent = CloudCostTracker::create_billing_agent(
                resource_class, {:logger => @log})
        if agent
          agents[resource_class] = agent
          agent.setup
        end
      end
      resources.each do |resource|
        if agent = agents[resource.class]
          agent.write_billing_record_for(resource)
        end
      end
    end
  end
end
