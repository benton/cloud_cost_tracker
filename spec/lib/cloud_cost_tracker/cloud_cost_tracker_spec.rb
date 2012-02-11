module CloudCostTracker
  describe '#create_billing_agents' do
    context "for a resource with only a single BillingPolicy defined" do
      it "returns an Array with the correct ResourceBillingPolicy subclass" do
      end
    end
    context "for a resource with several BillingPolicy classes" do
      it "returns an Array with the correct ResourceBillingPolicy subclass" do
        agents = CloudCostTracker::create_billing_agents(FAKE_RDS.servers.new.class)
        agent_classes = agents.map {|agent| agent.class.name.split('::').last}
        agent_classes.should include 'ServerBillingPolicy'
        agent_classes.should include 'ServerStorageBillingPolicy'
      end
    end
    context "for a resource whose BillingPolicy class is not defined" do
      it "returns an empty Array" do
        CloudCostTracker::create_billing_agents(double("x").class).should == []
      end
    end
  end
end
