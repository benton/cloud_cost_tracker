module CloudCostTracker
  module Billing
    module Compute
      module AWS
        # The default billing policy for Amazon EC2 server instances
        class ServerBillingPolicy < ResourceBillingPolicy
          # The YAML pricing data is read from config/billing
          CENTS_PER_HOUR = YAML.load(File.read File.join(
          CONSTANTS_DIR, 'compute-aws-servers', 'us-east-on_demand.yml'))

          # Returns the storage cost for a given EC2 server
          # over some duration (in seconds)
          def get_cost_for_duration(ec2_server, duration)
            return 0.0 if ec2_server.state =~ /(stopped|terminated)/
            hourly_cost = CENTS_PER_HOUR[platform_for(ec2_server)][ec2_server.flavor_id]
            (hourly_cost * duration) / SECONDS_PER_HOUR
          end

          # Returns either 'windows' or 'unix', based on this instance's platform
          def platform_for(resource)
            ('windows' == resource.platform) ? 'windows' : 'unix'
          end

        end
      end
    end
  end
end
