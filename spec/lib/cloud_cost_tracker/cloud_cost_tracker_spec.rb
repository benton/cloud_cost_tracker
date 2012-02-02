module CloudCostTracker
  describe '#create_billing_agent' do
    context "with a resource whose BillingPolicy class is defined" do
      it "returns an instance of the ResourceBillingPolicy subclass" do
        CloudCostTracker::create_billing_agent(FAKE_AWS.servers.new.class).
          should be_an_instance_of(
            Billing::Resources::Compute::AWS::ServerBillingPolicy
          )
      end
    end
    context "with a resource whose BillingPolicy class is not defined" do
      it "returns nil" do
        CloudCostTracker::create_billing_agent(double("x").class).should == nil
      end
    end
  end
end
