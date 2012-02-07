module CloudCostTracker
  module Billing
    module Resources
      module Storage
        module AWS
          class DirectoryBillingPolicy < ResourceBillingPolicy
            # Load the pricing data
            CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
              CONSTANTS_DIR, 'storage-aws-directories.yml'))

            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(resource, duration)
              CENTS_PER_GB_PER_MONTH[zone(resource)] * total_size(resource) *
                duration / SECONDS_PER_MONTH
            end

            # chop the availability zone letter from the region
            def zone(resource)
              'us-east-1'
            end

            # Returns the total size of all a bucket's objecgts, in GB
            def total_size(bucket)
               # check for saved value
              return @bucket_size[bucket] if @bucket_size[bucket]
              @log.warn "Computing size for bucket #{bucket.tracker_description}"
              total_bytes = 0.0
              bucket.files.each {|object| total_bytes += object.content_length}
              @log.warn "total bytes =  #{total_bytes}"
              # save the total size for later
              @bucket_size[bucket] = total_bytes / BYTES_PER_GB.to_f
              @bucket_size[bucket]
            end

            # remember each bucket size, because iterating over the objects is
            # slow, and get_cost_for_duration is called twice
            def setup
              @bucket_size = Hash.new
            end

          end
        end
      end
    end
  end
end
