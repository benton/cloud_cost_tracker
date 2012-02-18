module CloudCostTracker
  module Billing
    module Compute
      module AWS
        # The default billing policy for Amazon EBS Volumes
        class VolumeBillingPolicy < ResourceBillingPolicy
          # The YAML pricing data is read from config/billing
          CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
          CONSTANTS_DIR, 'compute-aws-volumes.yml'))

          # Returns the storage cost for a given EBS Volume
          # over some duration (in seconds)
          def get_cost_for_duration(volume, duration)
            return 0.0 if volume.state =~ /(deleting|deleted)/
            CENTS_PER_GB_PER_MONTH[zone(volume)] * volume.size *
            duration / SECONDS_PER_MONTH
          end

          # Chops the availability zone letter from the region
          def zone(resource)
            resource.availability_zone.chop
          end

          def billing_type ; "EBS volume storage" end

        end
      end
    end
  end
end
