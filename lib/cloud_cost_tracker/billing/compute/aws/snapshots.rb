module CloudCostTracker
  module Billing
    module Compute
      module AWS
        # The default billing policy for Amazon EBS Snapshots
        #
        # *NOT REALLY WORKING* - AWS does not report the size
        # of snapshots, so there's no way to accurately verify the cost!  :(
        class SnapshotBillingPolicy < ResourceBillingPolicy
          # The YAML pricing data is read from config/billing
          CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
          CONSTANTS_DIR, 'compute-aws-snapshots.yml'))

          # Returns the storage cost for a given EBS Snapshot
          # over some duration (in seconds)
          # TODO - Make an estimate based on lineage and volume size
          # This code is only accurate if the snapshot is the first for its volume
          def get_cost_for_duration(snapshot, duration)
            return 0.0  # TEMPORARILY DISABLED UNTIL WORKAROUND IS FOUND
            CENTS_PER_GB_PER_MONTH[zone(snapshot)] * snapshot.volume_size *
            duration / SECONDS_PER_MONTH
          end

          # Follows the snapshot's volume and returns its region, and
          # chops the availability zone letter from the region
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
