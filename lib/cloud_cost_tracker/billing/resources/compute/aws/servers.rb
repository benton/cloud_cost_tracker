module CloudCostTracker
  module Billing
    module Resources
      module Compute
        module AWS
          class ServerBillingPolicy < ResourceBillingPolicy
            # From http://aws.amazon.com/ec2/pricing/
            CENTS_PER_HOUR = {
              'unix' => {
                # Standard On-Demand Instances
                'm1.small'    => 8.5,
                'm1.large'    => 34.0,
                'm1.xlarge'   => 68.0,
                # Micro On-Demand Instances
                't1.micro'    => 2.0,
                # Hi-Memory On-Demand Instances
                'm2.xlarge'   => 50.0,
                'm2.2xlarge'  => 100.0,
                'm2.4xlarge'  => 200.0,
                # Hi-CPU On-Demand Instances
                'c1.medium'   => 17.0,
                'c1.xlarge'   => 68.0,
                # Cluster Compute Instances
                'cc1.4xlarge' => 130.0,
                'cc1.8xlarge' => 240.0,
                # Cluster GPU Instances
                'cg1.4xlarge' => 210.0,
              },
              'windows' => {
                # Standard On-Demand Instances
                'm1.small'    => 12.0,
                'm1.large'    => 48.0,
                'm1.xlarge'   => 96.0,
                # Micro On-Demand Instances
                't1.micro'    => 3.0,
                # Hi-Memory On-Demand Instances
                'm2.xlarge'   => 62.0,
                'm2.2xlarge'  => 124.0,
                'm2.4xlarge'  => 248.0,
                # Hi-CPU On-Demand Instances
                'c1.medium'   => 29.0,
                'c1.xlarge'   => 116.0,
                # Cluster Compute Instances
                'cc1.4xlarge' => 161.0,
                'cc1.8xlarge' => 297.0,
                # Cluster GPU Instances
                'cg1.4xlarge' => 260.0,
              },
            }

            # returns the cost for a particular resource over some duration (in seconds)
            def get_cost_for_duration(duration)
              hourly_cost = CENTS_PER_HOUR[platform][@resource.flavor_id]
              (hourly_cost * duration) / 3600.0
            end

            def platform
              ('windows' == @resource.platform) ? 'windows' : 'unix'
            end

          end
        end
      end
    end
  end
end
