module CloudCostTracker
  module Billing
    module Resources
      module AWS
        module RDS
          class ServerBillingPolicy < ResourceBillingPolicy
            # Load the pricing data
            CENTS_PER_HOUR = YAML.load(File.read File.join(
              CONSTANTS_DIR, 'rds-aws-servers', 'us-east-on_demand-mysql.yml'))

            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(resource, duration)
              hourly_cost = CENTS_PER_HOUR[zone_setting(resource)][resource.flavor_id]
              (hourly_cost * duration) / SECONDS_PER_HOUR
            end

            # returns either 'windows' or 'unix', 
            # depending on whether this RDS server is multi-AZ
            def zone_setting(resource)
              resource.multi_az ? 'multi_az' : 'standard'
            end

          end
        end
      end
    end
  end
end
