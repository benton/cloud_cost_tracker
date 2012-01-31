module CloudCostTracker
  module Billing
    module Resources
      module Compute
        module AWS
          class VolumeBillingPolicy < ResourceBillingPolicy
            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(duration)
              3.0
            end
          end
        end
      end
    end
  end
end
