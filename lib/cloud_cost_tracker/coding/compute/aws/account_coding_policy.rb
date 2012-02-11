module CloudCostTracker
  module Coding
    module Compute
      module AWS
        # Defines the default order in which EC2 resources get "coded"
        class AccountCodingPolicy < CloudCostTracker::Coding::AccountCodingPolicy

          # Defines the order in which EC2 resources are coded
          # @return [Array <Class>] the class names, in preferred coding order
          def priority_classes
            [
              Fog::Compute::AWS::Tag,
              Fog::Compute::AWS::SecurityGroup,
              Fog::Compute::AWS::KeyPair,
              Fog::Compute::AWS::Server,
              Fog::Compute::AWS::Snapshot,
              Fog::Compute::AWS::Volume,
              Fog::Compute::AWS::Address,
            ]
          end

          # Acount-wide coding strategy for coding EC2 resources
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
