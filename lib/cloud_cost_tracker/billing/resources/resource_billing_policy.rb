# Abstract class, defines a generic Billing Policy that always returns 0.0 cost
module CloudCostTracker
  module Billing
    module Resources
      class ResourceBillingPolicy
        include CloudCostTracker

        # Creates an object that implements a default (zero-cost) billing policy
        # @param [Hash] options optional parameters:
        #  - :logger - a Ruby Logger-compatible object
        def initialize(options={})
          @log = options[:logger] || FogTracker.default_logger
          setup
        end

        # Used by subclasses to perform setup each time an account is billed
        # High-latency operations like network transactions that are not
        # per-resource should be performed here
        def setup ; end

        # returns the cost for a particular resource over some duration (in seconds)
        def get_cost_for_duration(resource, duration) ; 0.0 end

        # Creates or Updates a BillingRecord for this BillingPolicy's @resource
        def write_billing_record_for(resource)
          account        = resource.tracker_account
          resource_type  = (resource.class.name.match(/::([^:]+)$/))[1]
          polling_time   = account[:polling_time].to_i
          new_record     = BillingRecord.new(
            :provider       => account[:provider],
            :service        => account[:service],
            :account        => account[:name],
            :resource_id    => resource.identity,
            :resource_type  => resource_type,
            :start_time     => Time.now - polling_time,
            :stop_time      => Time.now,
            :cost_per_hour  => get_cost_for_duration(resource, 3600),
            :total_cost     => get_cost_for_duration(resource, polling_time)
          )
          # Combine BillingRecords within @polling_time of one another
          last_record = BillingRecord.find_last_matching_record(new_record)
          if last_record && last_record.overlaps_with(new_record, polling_time)
            @log.debug "Updating record #{last_record.id}"+
                        " for #{resource.tracker_description}"
            last_record.update_from new_record
          else
            @log.debug "Creating new record for #{resource.tracker_description}"
            new_record.save!
          end
        end
      end
    end
  end
end
