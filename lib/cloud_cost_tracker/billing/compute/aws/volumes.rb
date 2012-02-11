module CloudCostTracker
  module Billing
    module Compute
      module AWS
        class VolumeBillingPolicy < ResourceBillingPolicy
          # Load the pricing data
          CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
          CONSTANTS_DIR, 'compute-aws-volumes.yml'))

          # returns the cost for a particular resource over some duration (in seconds)
          def get_cost_for_duration(resource, duration)
            return 0.0 if resource.state =~ /(deleting|deleted)/
            CENTS_PER_GB_PER_MONTH[zone(resource)] * resource.size *
            duration / SECONDS_PER_MONTH
          end

          # chop the availability zone letter from the region
          def zone(resource)
            resource.availability_zone.chop
          end
        end
      end
    end
  end
end
