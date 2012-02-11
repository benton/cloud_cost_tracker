module CloudCostTracker
  module Billing
    module Resources
      module AWS
        module RDS
          class ServerStorageBillingPolicy < ResourceBillingPolicy
            # Load the pricing data
            CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
              CONSTANTS_DIR, 'rds-aws-servers', 'us-east-on_demand-storage.yml'))

            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(resource, duration)
              CENTS_PER_GB_PER_MONTH[zone_setting(resource)] *
                resource.allocated_storage * duration / SECONDS_PER_MONTH
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
