module CloudCostTracker
  module Billing
    module Resources
      module Compute
        module AWS
          class SnapshotBillingPolicy < ResourceBillingPolicy
            # Load the pricing data
            CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
              CONSTANTS_DIR, 'compute-aws-snapshots.yml'))

            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(resource, duration)
              CENTS_PER_GB_PER_MONTH[zone(resource)] * resource.size *
                duration / SECONDS_PER_MONTH
            end

            # Follow the snapshot's volume and return its region
            # chop the availability zone letter from the region
            def zone(resource)
              (resource.account_resources('volumes').select do |v|
                v.identity == resource.volume_id
              end).first.availability_zone.chop
            end

          end
        end
      end
    end
  end
end
