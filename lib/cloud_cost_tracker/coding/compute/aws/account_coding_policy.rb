module CloudCostTracker
  module Coding
    module Compute
      module AWS
        # Implements the logic for attaching billing codes to all resources
        # in a single AWS EC2 account, and defines the default order in which
        # EC2 resources get coded.
        class AccountCodingPolicy < CloudCostTracker::Coding::AccountCodingPolicy

          # Defines the order in which EC2 resources are coded.
          # @return [Array <Class>] the class names, in preferred coding order
          def priority_classes
            [
              Fog::Compute::AWS::Tag,
              Fog::Compute::AWS::SecurityGroup,
              Fog::Compute::AWS::KeyPair,
              Fog::Compute::AWS::Server,    # pulls codes from security group
              Fog::Compute::AWS::Volume,    # pulls codes from server
              Fog::Compute::AWS::Snapshot,  # pulls codes from volume
              Fog::Compute::AWS::Address,
            ]
          end

          # Translates all AWS Tags into Billing Codes
          def attach_account_codes(resource)
            if resource.respond_to?(:tags) and resource.tags
              resource.tags.each do |key, value|
                resource.code(key, value)
              end
            end
          end

        end
      end
    end
  end
end
