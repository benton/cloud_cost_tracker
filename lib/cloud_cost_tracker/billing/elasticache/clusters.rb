module CloudCostTracker
  module Billing
    module AWS
      module Elasticache
        # The default billing policy for Amazon Elasticache Clusters
        class ClusterBillingPolicy < ResourceBillingPolicy
          # The YAML pricing data is read from config/billing
          CENTS_PER_HOUR = YAML.load(File.read File.join(
            CONSTANTS_DIR, 'elasticache-aws.yml'))

          def billing_type ; "Elasticache Cluster runtime" end

          # Returns the storage cost for a given Elasticache Cluster
          # over some duration (in seconds)
          def get_cost_for_duration(cluster, duration)
            #@log.warn "Calculating cost for #{cluster.tracker_description}"
            return 0.0 if cluster.status =~ /(stopped|terminated)/
            hourly_cost = cluster.num_nodes *
              CENTS_PER_HOUR[region(cluster)][cluster.node_type]
            (hourly_cost * duration) / SECONDS_PER_HOUR
          end

          # Chops the availability zone letter from the availability zone
          # and returns it as a string. e.g., "us-east-XXXXX" => "us-east"
          def region(cluster)
            cluster.zone.split('-')[0..1].join('-')
          end

        end
      end
    end
  end
end
