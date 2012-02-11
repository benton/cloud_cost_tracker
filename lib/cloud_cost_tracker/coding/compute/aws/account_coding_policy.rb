module CloudCostTracker
  module Coding
    module Compute
      module AWS
        # Defines the default order in which resources get "coded"
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

        end
      end
    end
  end
end
