module CloudCostTracker
  module Billing
    module Resources
      module Compute
        module AWS
          class VolumeBillingPolicy < ResourceBillingPolicy
            # Load the pricing data
            CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
              CONSTANTS_DIR, 'compute-aws-volumes.yml'))

            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(duration)
              CENTS_PER_GB_PER_MONTH * volume_size_in_gb * duration / SECONDS_PER_MONTH
            end
          end
        end
      end
    end
  end
end
