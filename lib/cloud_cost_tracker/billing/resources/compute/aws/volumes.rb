require 'cloud_cost_tracker/billing/resources/resource_billing_policy'
module CloudCostTracker
  module Billing
    module Resources
      module Compute
        module AWS
          class VolumeBillingPolicy < ResourceBillingPolicy
            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(resource, duration)
              3.0
            end
          end
        end
      end
    end
  end
end
