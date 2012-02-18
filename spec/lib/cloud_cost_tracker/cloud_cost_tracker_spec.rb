module CloudCostTracker

  describe '#create_billing_agents' do
    context "for a resource with only a single BillingPolicy defined" do
      it "returns an Array with the correct ResourceBillingPolicy subclass" do
        CloudCostTracker::create_billing_agents(FAKE_AWS.servers.new.class).
          first.class.should == Billing::Compute::AWS::ServerBillingPolicy
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

  describe '#create_coding_agents' do
    context "for a resource with only a single CodingPolicy defined" do
      it "returns an Array with the correct ResourceCodingPolicy subclass" do
        CloudCostTracker::create_coding_agents(FAKE_AWS.volumes.new.class).
          first.class.should == Coding::Compute::AWS::VolumeCodingPolicy
      end
    end
    context "for a resource with several CodingPolicy classes" do
      #it "returns an Array with the correct ResourceCodingPolicy subclass" do
      #  pending("need for multiple coding policies per resource")
      #  agents = CloudCostTracker::create_coding_agents(FAKE_RDS.servers.new.class)
      #  agent_classes = agents.map {|agent| agent.class.name.split('::').last}
      #  agent_classes.should include 'ServerCodingPolicy'
      #  agent_classes.should include 'ServerStorageCodingPolicy'
      #end
    end
    context "for a resource whose CodingPolicy class is not defined" do
      it "returns an empty Array" do
        CloudCostTracker::create_coding_agents(double("x").class).should == []
      end
    end
  end

  describe '#account_coding_class' do
    context "for a Fog service with an AccountCodingPolicy subclass" do
      it "returns the correct AccountCodingPolicy subclass" do
        CloudCostTracker::account_coding_class('Compute', 'AWS').
          should == Coding::Compute::AWS::AccountCodingPolicy
      end
    end
  end

end
