# Abstract class, defines a generic Billing Policy that always returns 0.0 cost
module CloudCostTracker
  module Billing

    PRECISION     = 10  # (Should match database migration precision)
    # Defines a directory for holding YML pricing constants
    CONSTANTS_DIR = File.join(File.dirname(__FILE__),'../../../config/billing')

    # Some time and size constants

    SECONDS_PER_MINUTE  = 60.0
    SECONDS_PER_HOUR    = SECONDS_PER_MINUTE * 60
    SECONDS_PER_DAY     = SECONDS_PER_HOUR * 24
    SECONDS_PER_YEAR    = SECONDS_PER_DAY * 365
    SECONDS_PER_MONTH   = SECONDS_PER_YEAR / 12
    BYTES_PER_KB        = 1024
    BYTES_PER_MB        = BYTES_PER_KB * 1024
    BYTES_PER_GB        = BYTES_PER_MB * 1024

    # Implements the logic for billing a single resource.
    # All Billing Policies should inherit from this class, and define
    # {#get_cost_for_duration}
    class ResourceBillingPolicy
      include CloudCostTracker

      # Don't override this method - use {#setup} instead for
      # one-time behavior
      # @param [Hash] options optional parameters:
      #  - :logger - a Ruby Logger-compatible object
      def initialize(options={})
        @log = options[:logger] || FogTracker.default_logger
      end

      # An initializer called by the framework once per billling cycle.
      # Override this method if you need to perform high-latency operations,
      # like network transactions, that should not be performed per-resource.
      def setup(resources) ; end

      # Returns the cost for a particular resource over some duration in seconds.
      #  ALL BILLING POLICY SUBCLASSES SHOULD OVERRIDE THIS METHOD
      def get_cost_for_duration(resource, duration) ; 1.0 end

      # Returns the default billing type for this policy.
      # Override this to set a human-readable name for the policy.
      # Defaults to the last part of the subclass name.
      def billing_type
        self.class.name.split('::').last  #(defaluts to class name)
      end

      # Creates or Updates a BillingRecord for this BillingPolicy's resource.
      # Don't override this -- it's called once for each resource by the
      # {CloudCostTracker::Billing::AccountBillingPolicy}.
      # @param [Fog::Model] resource the resource for the record to be written
      # @param [Float] hourly_rate the resource's hourly rate for this period
      # @param [Float] total the resource's total cost for this period
      # @param [Time] start_time the start time for any new BillingRecords
      # @param [Time] end_time the start time for any new BillingRecords
      def write_billing_record_for(resource, hourly_rate, total,
        start_time, end_time)
        account         = resource.tracker_account
        resource_type   = resource.class.name.split('::').last
        return if total == 0.0  # Write no record if the cost is zero
        new_record = BillingRecord.new(
          :provider       => account[:provider],
          :service        => account[:service],
          :account        => account[:name],
          :resource_id    => resource.identity,
          :resource_type  => resource_type,
          :billing_type   => billing_type,
          :start_time     => start_time,
          :stop_time      => end_time,
          :cost_per_hour  => hourly_rate,
          :total_cost     => total
        )
        new_record.set_codes(resource.billing_codes)
        # Combine BillingRecords within maximim_gap of one another
        write_new_record = true
        last_record = BillingRecord.most_recent_like(new_record)
        # If the previous record for this resource/billing type has the same
        # hourly rate and billing codes, just update the previous record
        merge_window = account[:delay].to_i
        if last_record && last_record.overlaps_with(new_record, merge_window)
          if (last_record.cost_per_hour.round(PRECISION) ==
              new_record.cost_per_hour.round(PRECISION)) &&
              (last_record.billing_codes == new_record.billing_codes)
            @log.debug "Updating record #{last_record.id}"+
                        " for #{resource.tracker_description}"
            last_record.merge_with new_record
            write_new_record = false
          else  # If the previous record has different rate or codes...
            # Make the new record begin where the previous one leaves off
            new_record.start_time = last_record.stop_time
          end
        end
        if write_new_record
          @log.debug "Creating new record for #{resource.tracker_description}"
          new_record.save!
        end
      end
    end
  end
end
