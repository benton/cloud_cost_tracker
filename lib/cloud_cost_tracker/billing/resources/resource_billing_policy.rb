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
        end

        # returns the cost for a particular resource since a given point in time
        # if this returns -1, get_cost_for_time will be called instead
        def get_cost_since_time(date_time) ; nil end

        # returns the cost for a particular resource over some duration (in seconds)
        def get_cost_for_duration(duration) ; 0.0 end

        # Creates or Updates a BillingRecord for this BillingPolicy's @resource
        def write_billing_record
          if existing_record = find_record_to_update
            update_existing_billing_record existing_record
          else
            create_new_billing_record
          end
          total_costs
        end

        private

        # Returns the latest BillingRecord for this resource if it is unchanged
        # and if its stop_time is less than the polling delay from Time.now
        # if no such BillingRecord is found, returns nil
        def find_record_to_update
          nil
        end

        # Creates a new BillingRecord object and writes it to the database
        def create_new_billing_record
          billing_params = {
            :provider       => @resource.tracker_account[:provider],
            :service        => @resource.tracker_account[:service],
            :account        => @resource.tracker_account[:name],
            :resource_id    => @resource.identity,
            :resource_type  => (@resource.class.name.match(/::([^:]+)$/))[1],
            :start_time     => Time.now - @resource.tracker_account[:polling_time],
            :stop_time      => Time.now,
            :cost_per_hour  => get_cost_for_duration(3600),
            :total_cost     => total_costs
          }
          @log.debug "Creating BillingRecord: #{billing_params.inspect}"
          CloudCostTracker::BillingRecord.create!(billing_params)
        end

        # Updates the time and total on a BillingRecord object
        # and writes it to the database
        def update_existing_billing_record(billing_record)

        end

        def total_costs
          total = get_cost_since_time(Time.now)
          total ||= get_cost_for_duration(60)
          @log.debug "Calculated cost #{total} for #{@resource.class} "+
            "#{@resource.identity}"
          total
        end

      end
    end
  end
end
