module CloudCostTracker
  module Billing
    # Implements the logic for billing all resources in a single account.
    # Initializes the necessary ResourceBillingPolicy objects, sorts the
    # resources by policy, and calls get_cost_for_duration twice on each
    # resource's policy to compute the charges.
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
        @account = resources.first.tracker_account # Save account info
      end

      # An initializer called by the framework once per billing cycle.
      # Override this method if you need to perform high-latency operations,
      # like network transactions, that should not be performed per-resource.
      def setup(resources) ; end

      # Defines the default method for billing all resources
      def bill_for(resources)
        return if resources.empty?
        setup_resource_billing_agents(resources)
        delay         = @account[:delay].to_i
        bill_end      = Time.now
        bill_start    = @account[:preceeding_update_time] || (bill_end - delay)
        bill_duration = bill_end - bill_start
        # calculate the hourly and total cost for all resources, by type
        @agents.keys.each do |resource_class|
          collection = resources.select {|r| r.class == resource_class}
          collection_name = collection.first.collection.class.name.split('::').last
          @log.info "Computing costs for #{collection.size}"+
            " #{collection_name} in account #{@account[:name]}"
          collection.each do |resource|
            @log.debug "Computing costs for #{resource.tracker_description}"+
              " in account #{@account[:name]}"
            @agents[resource.class].each do |billing_agent|
              @total_cost[resource][billing_agent] = billing_agent.
                get_cost_for_duration(resource, bill_duration).round(PRECISION)
              @hourly_cost[resource][billing_agent] = billing_agent.
                get_cost_for_duration(resource, SECONDS_PER_HOUR).round(PRECISION)
            @log.debug "Computed costs for #{resource.tracker_description}"+
              " in account #{@account[:name]}"
            end
          end
          @log.info "Computed costs for #{collection.size}"+
            " #{collection_name} in account #{@account[:name]}"
        end
        write_records_for(resources, bill_start, bill_end)
      end

      private

      # Writes the billing records - @total_cost and @total_cost must be populated
      # @param [Array <Fog::Model>] resources the resources to write records for
      # @param [Time] start_time the start time for any new BillingRecords
      def write_records_for(resources, start_time, end_time)
        ActiveRecord::Base.connection_pool.with_connection do
          # Write BillingRecords for all resources, by type
          @agents.keys.each do |resource_class|
            collection = resources.select {|r| r.class == resource_class}
            collection_name = collection.first.collection.class.name.split('::').last
            @log.info "Writing billing records for #{collection.size} "+
              "#{collection_name} in account #{@account[:name]}"
            collection.each do |resource|
              @agents[resource.class].each do |billing_agent|
                billing_agent.write_billing_record_for(resource,
                  @hourly_cost[resource][billing_agent],
                  @total_cost[resource][billing_agent],
                  start_time, end_time
                )
              end
            end
            @log.info "Wrote billing records for #{collection.size} "+
              "#{collection_name} in account #{@account[:name]}"
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
          @agents.delete(resource_class) if @agents[resource_class].empty?
        end
      end

    end
  end
end
