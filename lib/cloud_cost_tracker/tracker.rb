module CloudCostTracker

  # Tracks the resources in one or more Fog accounts in an ActiveRecord database
  class Tracker

    # each CloudCostTracker is a thin wrapper around it's @tracker,
    require 'fog_tracker'     # which is a FogTracker:Tracker
    extend Forwardable        # most public methods are delegated
    def_delegators :@tracker,:start,:stop,:query,:[],:update,
            :running?,:types_for_account,:logger

    attr_reader :accounts

    # Creates an object for tracking Fog accounts in an ActiveRecord database
    # @param [Hash] accounts a Hash of account information
    #    (see accounts.yml.example)
    # @param [Hash] options optional additional parameters:
    #  - :delay (Integer) - Override time between polling of accounts
    #    (should take a single Exception as its only required parameter)
    #  - :logger - a Ruby Logger-compatible object
    def initialize(accounts = {}, options={})
      @delay    = options[:delay]
      @log      = options[:logger] || FogTracker.default_logger
      @running  = false
      @accounts = setup_fog_tracker(accounts)
    end

    private

    # Creates a FogTracker::Tracker that calls bill_for_account
    # each time an account is refreshed
    def setup_fog_tracker(accounts)
      @tracker = FogTracker::Tracker.new(accounts,
        {:delay => @delay, :logger => @log,
          :callback => Proc.new do |resources|
            checked_resources = sanity_check(resources)
            code_resources(checked_resources)
            bill_for_resources(checked_resources)
          end
        }
      )
      @tracker.accounts
    end


    # Make sure returned resources are billable and codeable
    # @param [Array<Fog::Model>] resources the resources to check
    # @return [Array<Fog::Model>] the resources deemed OK
    def sanity_check(resources)
      resources.select do |resource|
        if resource.identity == nil
          @log.warn "Found a Fog::Model with no identity. Removing it..."
          @log.debug "BAD Fog::Model instance: #{resource.inspect}"
          false   # return false from select to indicate resource is bad
        else
          true    # return true from select to indicate resource is OK
        end
      end
    end

    # Adds billing codes for all resources
    def code_resources(resources)
      return if resources.empty?
      account = resources.first.tracker_account
      @log.info "Generating billing codes for account #{account[:name]}"
      coding_class = CloudCostTracker::account_coding_class(
        account[:service], account[:provider])
      coding_agent = coding_class.new(resources, {:logger => @log})
      coding_agent.setup(resources)
      coding_agent.code(resources)
      @log.info "Generated billing codes for account #{account[:name]}"
    end

    # Generates BillingRecords for all Resources in account named +account_name+
    def bill_for_resources(resources)
      return if resources.empty?
      account = resources.first.tracker_account
      @log.info "Computing costs for account #{account[:name]}"
      billing_agent = Billing::AccountBillingPolicy.new(
                        resources, {:logger => @log})
      billing_agent.setup(resources)
      billing_agent.bill_for(resources)
      @log.info "Wrote billing records for account #{account[:name]}"
    end
  end
end
