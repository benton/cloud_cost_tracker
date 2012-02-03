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
            # TODO - AWS does not seem to report the size of the snapshot, so there's
            # no way to verify the cost!  :(
            # This code is only accurate if the snapshot is the first for its volume
            def get_cost_for_duration(resource, duration)
              CENTS_PER_GB_PER_MONTH[zone(resource)] * resource.volume_size *
                duration / SECONDS_PER_MONTH
            end

            # Follow the snapshot's volume and return its region
            # chop the availability zone letter from the region
            def zone(resource)
              volume = resource.account_resources('volumes').find do |v|
                v.identity == resource.volume_id
              end
              if volume && volume.availability_zone
                volume.availability_zone.chop
              else
                "us-east-1"
              end
            end

          end
        end
      end
    end
  end
end
