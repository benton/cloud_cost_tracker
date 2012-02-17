module CloudCostTracker
  module Billing
    describe AccountBillingPolicy do

      before(:each) do
        @server = FAKE_AWS.servers.new
        @db = FAKE_RDS.servers.new
        @default_policy = AccountBillingPolicy.new([@server, @db])
      end

      describe '#setup' do
        it "does nothing in the default implementation" do
          (Proc.new {@default_policy.setup(nil)}).should_not raise_error
        end
      end

      describe '#bill_for' do
        it 'calls set, get_cost_for_duration, and write_billing_record_for'+
           ' on each resource billing policy' do
          resource_policy = double "fake ResourceBillingPolicy"
          resource_policy.stub(:get_cost_for_duration).and_return 1.0
          CloudCostTracker.stub(:create_billing_agents).and_return([resource_policy])
          resource_policy.should_receive(:setup).with([@server, @db]).exactly(4).times
          account_policy = AccountBillingPolicy.new([@server, @db])
          resource_policy.should_receive(:get_cost_for_duration)
          resource_policy.should_receive(:write_billing_record_for).exactly(2).times
          account_policy.bill_for([@server, @db])
        end
      end

    end
  end
end
