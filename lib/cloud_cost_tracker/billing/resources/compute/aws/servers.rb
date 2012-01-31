module CloudCostTracker
  module Billing
    module Resources
      module Compute
        module AWS
          class ServerBillingPolicy < ResourceBillingPolicy
            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(duration)
              1.0
            end
          end
        end
      end
    end
  end
end
