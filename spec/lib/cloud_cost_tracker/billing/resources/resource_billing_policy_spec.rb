module CloudCostTracker
  module Billing
    module Resources
      describe ResourceBillingPolicy do

        before(:each) do
          @resource = FAKE_AWS.servers.new
          @default_policy = ResourceBillingPolicy.new
        end

        describe '#get_cost_for_duration' do
          it 'should always return zero cost, even with nil arguments' do
            @default_policy.get_cost_for_duration(nil).should == 0.0
          end
        end

      end
    end
  end
end
