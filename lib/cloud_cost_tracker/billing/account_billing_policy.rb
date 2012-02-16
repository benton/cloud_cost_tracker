module CloudCostTracker
  module Billing
    class AccountBillingPolicy

      # Creates an object that implements the default account billing policy
      # @param [Array <Fog::Model>] resources the resources to bill for
      # @param [Hash] options optional parameters:
      #  - :logger - a Ruby Logger-compatible object
      def initialize(resources, options={})
        @log = options[:logger] || FogTracker.default_logger
        setup_resource_billing_agents(resources)
        # Initialize data structures for caching costs
        # the hourly cost for each resource, and billing agent
        @hourly_cost  = Hash.new # @hourly_cost[resource][agent]
        # the total cost for each resource, and billing agent
        @total_cost   = Hash.new # @total_cost[resource][agent]
        resources.each do |resource|
          @hourly_cost[resource] ||= Hash.new
          @total_cost[resource]  ||= Hash.new
        end
      end

      # Used by subclasses to perform setup each time an account's
      # resources are billed
      # High-latency operations like network transactions that are not
      # per-resource should be performed here
      def setup(resources) ; end

      # Defines the default method for billing all resources
      def bill_for(resources)
        return if resources.empty?
        account = resources.first.tracker_account   # Get account info
        delay = account[:delay].to_i
        start_billing = Time.now  # track how long billing takes
        # calculate the hourly and total cost for each resource
        resources.each do |resource|
          @agents[resource.class].each do |billing_agent|
            @total_cost[resource][billing_agent] = billing_agent.
              get_cost_for_duration(resource, delay).round(PRECISION)
            @hourly_cost[resource][billing_agent] = billing_agent.
              get_cost_for_duration(resource, SECONDS_PER_HOUR).round(PRECISION)
          end
        end
        billing_time = Time.now - start_billing
        @log.info "Generated costs for in #{billing_time} seconds "+
          "for account #{account[:name]}"
        write_records_for(resources, billing_time + delay)
      end

      private

      # Writes the billing records - @total_cost and @total_cost must be populated
      # @param [Array <Fog::Model>] resources the resources to write records for
      # @param [Integer] slack_time the maximum of seconds between overlapping records
      def write_records_for(resources, slack_time)
        ActiveRecord::Base.connection_pool.with_connection do
          resources.each do |resource|
            @agents[resource.class].each do |billing_agent|
              billing_agent.write_billing_record_for(resource,
                @hourly_cost[resource][billing_agent],
                @total_cost[resource][billing_agent],
                slack_time
              )
            end
          end
        end
      end

      # Builds a Hash of BillingPolicy agents, indexed by resource Class name
      def setup_resource_billing_agents(resources)
        @agents = Hash.new
        ((resources.collect {|r| r.class}).uniq).each do |resource_class|
          @agents[resource_class] = CloudCostTracker::create_billing_agents(
            resource_class, {:logger => @log})
          @agents[resource_class].each {|agent| agent.setup(resources)}
        end
      end

    end
  end
end
