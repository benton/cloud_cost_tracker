module CloudCostTracker
  module Coding
    module Compute
      module AWS
        class ServerCodingPolicy < ResourceCodingPolicy

          # Attaches Billing Codes (String pairs) to resource, as billing_codes
          def code(resource)
            resource.billing_codes = Array.new if resource
          end

        end
      end
    end
  end
end
