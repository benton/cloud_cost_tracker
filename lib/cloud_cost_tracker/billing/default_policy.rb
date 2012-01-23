# Abstract class, defines a generic Billing Policy that always returns 0.0 cost
module CloudCostTracker
  module Billing
    module Resources
      class ResourceBillingPolicy

        # Creates an object for billing Fog resources
        #
        # ==== Attributes
        #
        # * +account_name+ - the name of the account to bill for
        # * +account+ - the Hash of account information (see accounts.yml.example)
        # * +options+ - Hash of optional parameters
        #
        # ==== Options
        #
        # * +:logger+ - a Ruby Logger-compatible object
        def initialize(account_name, account, options={})
          @account_name = account_name
          @account      = account
          @log          = options[:logger] || CloudCostTracker.default_logger
        end

        # returns the cost for a particular resource since a given point in time
        # if this returns -1, get_cost_for_time will be called instead
        def get_cost_since_time(resource, date_time)
          -1
        end

        # returns the cost for a particular resource over some duration (in seconds)
        def get_cost_for_duration(resource, duration)
          0.0
        end

      end
    end
  end
end
