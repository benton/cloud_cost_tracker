module CloudCostTracker
  module Coding
    module Compute
      module AWS
        class ServerCodingPolicy < ResourceCodingPolicy

          # Attaches Billing Codes (String pairs) to resource, as billing_codes
          def code(aws_server)
            if aws_server.tags
              aws_server.tags.each do |key, value|
                aws_server.code(key, value)
              end
            end
          end

        end
      end
    end
  end
end
