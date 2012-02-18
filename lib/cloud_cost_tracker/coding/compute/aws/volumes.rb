module CloudCostTracker
  module Coding
    module Compute
      module AWS
        # Implements the logic for attaching billing codes to EBS Volumes
        class VolumeCodingPolicy < ResourceCodingPolicy

          # Copies all billing codes from any attached instance to this volume
          def code(ebs_volume)
            if (ebs_volume.state == "in-use") && (ebs_volume.server_id != "")
              server = ebs_volume.account_resources('servers').find do |server|
                server.identity == ebs_volume.server_id
              end
              if server
                server.billing_codes.each do |server_code|
                  ebs_volume.code(server_code[0], server_code[1])
                end
              end
            end
          end

        end
      end
    end
  end
end
