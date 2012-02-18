module CloudCostTracker
  module Billing
    module Storage
      module AWS
        # The default billing policy for Amazon S3 buckets
        class DirectoryBillingPolicy < ResourceBillingPolicy
          # The YAML pricing data is read from config/billing
          CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
          CONSTANTS_DIR, 'storage-aws-directories.yml'))

          # Returns the runtime cost for a given S3 bucket
          # over some duration (in seconds)
          def get_cost_for_duration(s3_bucket, duration)
            CENTS_PER_GB_PER_MONTH[zone(s3_bucket)] * total_size(s3_bucket) *
            duration / SECONDS_PER_MONTH
          end

          # Chops the availability zone letter from the region
          def zone(resource)
            'us-east-1'
          end

          # Returns the total size of all a bucket's objecs, in GB
          def total_size(bucket)
            # check for saved value
            return @bucket_size[bucket] if @bucket_size[bucket]
            @log.debug "Computing size for #{bucket.tracker_description}"
            total_bytes = 0
            bucket.files.each {|object| total_bytes += object.content_length}
            @log.debug "total bytes = #{total_bytes}"
            # save the total size for later
            @bucket_size[bucket] = total_bytes / BYTES_PER_GB.to_f
          end

          # Remembers each bucket size, because iterating over S3 objects is
          # slow, and get_cost_for_duration is called twice
          def setup(resources)
            @bucket_size = Hash.new
          end

        end
      end
    end
  end
end
