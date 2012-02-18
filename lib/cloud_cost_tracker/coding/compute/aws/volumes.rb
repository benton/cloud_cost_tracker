module CloudCostTracker
  module Coding
    module Compute
      module AWS
        # Implements the logic for attaching billing codes to EBS Volumes
        class VolumeCodingPolicy < ResourceCodingPolicy

          # Copies all billing codes from any attached instance to this volume
          def code(ebs_volume)
          end

        end
      end
    end
  end
end
