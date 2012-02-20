module CloudCostTracker
  module Coding
    module AWS
      module RDS
        # Implements the logic for attaching billing codes to RDS instances
        class ServerCodingPolicy < ResourceCodingPolicy

          # Indexes the security and parameter groups, so that BillingCodes
          # can be pulled from them quickly when code() is called
          def setup(resources)
            @acc_sec_groups = Hash.new    # Index the security groups
            resources.first.account_resources('security_groups').each do |group|
              @acc_sec_groups[group.identity] = group
            end
            @acc_param_groups = Hash.new  # Index the parameter groups
            resources.first.account_resources('parameter_groups').each do |group|
              @acc_param_groups[group.identity] = group
            end
          end

          # Copies all billing codes from this server's Groups
          def code(rds_server)
            code_from_security_group(rds_server)
            code_from_parameter_group(rds_server)
          end

          # Copies all billing codes from this server's Security Group
          def code_from_security_group(rds_server)
            if rds_server.db_security_groups
              server_groups = rds_server.db_security_groups.map do |group|
                @acc_sec_groups[group['DBSecurityGroupName']]
              end
              server_groups.each do |group|
                group.billing_codes.each do |billing_code|
                  rds_server.code(billing_code[0], billing_code[1])
                end
              end
            end
          end

          # Copies all billing codes from this server's Parameter Group
          def code_from_parameter_group(rds_server)
            if rds_server.db_parameter_groups
              server_groups = rds_server.db_parameter_groups.map do |group|
                @acc_param_groups[group['DBParameterGroupName']]
              end
              server_groups.each do |group|
                group.billing_codes.each do |billing_code|
                  rds_server.code(billing_code[0], billing_code[1])
                end
              end
            end
          end

        end
      end
    end
  end
end
