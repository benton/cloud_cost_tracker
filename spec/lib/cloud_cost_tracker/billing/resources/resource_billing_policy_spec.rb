module CloudCostTracker
  module Billing
    module Resources
      describe ResourceBillingPolicy do

        before(:each) do
          @default_policy = ResourceBillingPolicy.new
          @resource = double "a mock Fog::Model resource"
        end

        describe '#get_cost_since_time' do
          it 'should always return nil, even with nil arguments' do
            @default_policy.get_cost_since_time(nil, nil).should == nil
          end
        end

        describe '#get_cost_since_time' do
          it 'should always return zero cost, even with nil arguments' do
            @default_policy.get_cost_for_duration(nil, nil).should == 0.0
          end
        end

      end
    end
  end
end
