# Abstract class, defines a generic Billing Policy that always returns 0.0 cost
module CloudCostTracker
  module Billing

    PRECISION     = 10  # (Should match database migration precision)
    # Defines a directory for holding YML pricing constants
    CONSTANTS_DIR = File.join(File.dirname(__FILE__),'../../../config/billing')

    # Some time constants
    SECONDS_PER_HOUR  = 3600.0
    SECONDS_PER_DAY   = SECONDS_PER_HOUR * 24
    SECONDS_PER_YEAR  = SECONDS_PER_DAY * 365
    SECONDS_PER_MONTH = SECONDS_PER_YEAR / 12
    # Some size constants
    BYTES_PER_KB      = 1024
    BYTES_PER_MB      = BYTES_PER_KB * 1024
    BYTES_PER_GB      = BYTES_PER_MB * 1024

    class ResourceBillingPolicy
      include CloudCostTracker

      # Creates an object that implements a default (zero-cost) billing policy
      # @param [Hash] options optional parameters:
      #  - :logger - a Ruby Logger-compatible object
      def initialize(options={})
        @log = options[:logger] || FogTracker.default_logger
      end

      # Used by subclasses to perform setup each time an account is billed
      # High-latency operations like network transactions that are not
      # per-resource should be performed here
      def setup(resources) ; end

      # returns the cost for a particular resource over some duration in seconds
      def get_cost_for_duration(resource, duration) ; 1.0 end

      # Returns the default billing type for this policy
      def billing_type
        self.class.name.split('::').last  #(defaluts to class name)
      end

      # Creates or Updates a BillingRecord for this BillingPolicy's @resource
      # param [Float] hourly_rate the resource's hourly rate for this period
      # param [Float] hourly_rate the resource's total cost for this period
      # param [Integer] max_time the maximum separation between separate
      #  resource records, in seconds
      def write_billing_record_for(resource, hourly_rate, total, max_time = nil)
        account         = resource.tracker_account
        resource_type   = resource.class.name.split('::').last
        delay           = account[:delay].to_i
        maximum_gap     = max_time || delay
        return if total == 0.0  # Write no record if the cost is zero
        new_record = BillingRecord.new(
          :provider       => account[:provider],
          :service        => account[:service],
          :account        => account[:name],
          :resource_id    => resource.identity,
          :resource_type  => resource_type,
          :billing_type   => billing_type,
          :start_time     => Time.now - delay,
          :stop_time      => Time.now,
          :cost_per_hour  => hourly_rate,
          :total_cost     => total
        )
        new_record.set_codes(resource.billing_codes)
        # Combine BillingRecords within maximim_gap of one another
        last_record = BillingRecord.find_last_matching_record(new_record)
        if last_record && last_record.overlaps_with(new_record, maximum_gap)
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
