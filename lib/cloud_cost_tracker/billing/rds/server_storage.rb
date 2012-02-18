module CloudCostTracker
  module Billing
    module AWS
      module RDS
        # The default billing policy for Amazon RDS server storage costs
        class ServerStorageBillingPolicy < ResourceBillingPolicy
          # The YAML pricing data is read from config/billing
          CENTS_PER_GB_PER_MONTH = YAML.load(File.read File.join(
          CONSTANTS_DIR, 'rds-aws-servers', 'us-east-on_demand-storage.yml'))

          # Returns the storage cost for a given RDS server
          # over some duration (in seconds)
          def get_cost_for_duration(rds_server, duration)
            CENTS_PER_GB_PER_MONTH[zone_setting(rds_server)] *
            rds_server.allocated_storage * duration / SECONDS_PER_MONTH
          end

          # returns either 'multi_az' or 'standard',
          # depending on whether this RDS server is multi-AZ
          def zone_setting(resource)
            resource.multi_az ? 'multi_az' : 'standard'
          end

          def billing_type ; "RDS Instance storage" end

        end
      end
    end
  end
end
