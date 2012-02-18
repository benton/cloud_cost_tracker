module CloudCostTracker
  module Billing
    module AWS
      module RDS
        # The default billing policy for Amazon RDS server runtime costs
        class ServerBillingPolicy < ResourceBillingPolicy
          # The YAML pricing data is read from config/billing
          CENTS_PER_HOUR = YAML.load(File.read File.join(
            CONSTANTS_DIR, 'rds-aws-servers', 'us-east-on_demand-mysql.yml'))

          # Returns the runtime cost for a given RDS server
          # over some duration (in seconds)
          def get_cost_for_duration(rds_server, duration)
            hourly_cost =
              CENTS_PER_HOUR[zone_setting(rds_server)][rds_server.flavor_id]
            (hourly_cost * duration) / SECONDS_PER_HOUR
          end

          # returns either 'multi_az' or 'standard',
          # depending on whether this RDS server is multi-AZ
          def zone_setting(resource)
            resource.multi_az ? 'multi_az' : 'standard'
          end

          def billing_type ; "RDS Instance runtime" end

        end
      end
    end
  end
end
