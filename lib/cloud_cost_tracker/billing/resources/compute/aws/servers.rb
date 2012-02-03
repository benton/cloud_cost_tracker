module CloudCostTracker
  module Billing
    module Resources
      module Compute
        module AWS
          class ServerBillingPolicy < ResourceBillingPolicy
            # Load the pricing data
            CENTS_PER_HOUR = YAML.load(File.read File.join(
              CONSTANTS_DIR, 'compute-aws-servers', 'us-east-on_demand.yml'))

            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(resource, duration)
              return 0.0 if resource.state =~ /(stopped|terminated)/
              hourly_cost = CENTS_PER_HOUR[platform_for(resource)][resource.flavor_id]
              (hourly_cost * duration) / 3600.0
            end

            # returns either 'windows' or 'unix', based on this instance's platform
            def platform_for(resource)
              ('windows' == resource.platform) ? 'windows' : 'unix'
            end

          end
        end
      end
    end
  end
end
