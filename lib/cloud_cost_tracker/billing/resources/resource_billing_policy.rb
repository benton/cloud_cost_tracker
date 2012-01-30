# Abstract class, defines a generic Billing Policy that always returns 0.0 cost
module CloudCostTracker
  module Billing
    module Resources
      class ResourceBillingPolicy

        # Creates an object that implements a default (zero-cost) billing policy
        # @param [Hash] options optional parameters:
        #  - :logger - a Ruby Logger-compatible object
        def initialize(resource, options={})
          @resource = resource
          @log = options[:logger] || FogTracker.default_logger
          bill_resource
        end

        # returns the cost for a particular resource since a given point in time
        # if this returns -1, get_cost_for_time will be called instead
        def get_cost_since_time(date_time) ; nil end

        # returns the cost for a particular resource over some duration (in seconds)
        def get_cost_for_duration(duration) ; 0.0 end

        private

        # Creates or Updates the BillingRecord for an individual
        def bill_resource
          total = get_cost_since_time(Time.now)
          total ||= get_cost_for_duration(60)
          @log.info "Generated cost #{total} for #{@resource.class} "+
          "#{@resource.identity}"
        end

      end
    end
  end
end
