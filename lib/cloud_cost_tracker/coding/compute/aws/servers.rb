module CloudCostTracker
  module Coding
    module Compute
      module AWS
        # Implements the logic for attaching billing codes to EC2 servers
        class ServerCodingPolicy < ResourceCodingPolicy

          # Copies all billing codes from this server's Security Group
          def code(ec2_server)
            ec2_server.groups.each do |group_name|
              group = ec2_server.account_resources('security_groups').find do |g|
                g.identity == group_name
              end
              if group
                group.billing_codes.each do |billing_code|
                  ec2_server.code(billing_code[0], billing_code[1])
                end
              end
            end
          end

        end
      end
    end
  end
end
