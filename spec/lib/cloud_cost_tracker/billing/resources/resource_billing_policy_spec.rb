module CloudCostTracker
  module Billing
    module Resources
      describe ResourceBillingPolicy do

        before(:each) do
          @resource = FAKE_AWS.servers.new
          @default_policy = ResourceBillingPolicy.new(@resource)
        end

        describe '#get_cost_since_time' do
          it 'should always return nil, even with nil arguments' do
            @default_policy.get_cost_since_time(nil).should == nil
          end
        end

        describe '#get_cost_since_time' do
          it 'should always return zero cost, even with nil arguments' do
            @default_policy.get_cost_for_duration(nil).should == 0.0
          end
        end

      end
    end
  end
end
