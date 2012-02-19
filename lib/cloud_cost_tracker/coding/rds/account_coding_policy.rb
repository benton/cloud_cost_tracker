module CloudCostTracker
  module Coding
    module RDS
      module AWS
        # Implements the logic for attaching billing codes to all resources
        # in a single AWS RDS account, and defines the default order in which
        # RDS resources get coded.
        class AccountCodingPolicy < CloudCostTracker::Coding::AccountCodingPolicy

          # Defines the order in which EC2 resources are coded.
          # @return [Array <Class>] the class names, in preferred coding order
          def priority_classes
            [
              Fog::AWS::RDS::SecurityGroup,
              Fog::AWS::RDS::ParameterGroup,
              Fog::AWS::RDS::Server,    # pulls codes from security group
              Fog::AWS::RDS::Snapshot,  # pulls codes from server
            ]
          end

        end
      end
    end
  end
end
