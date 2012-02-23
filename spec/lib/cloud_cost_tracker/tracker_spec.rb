module CloudCostTracker
  describe Tracker do

    before(:each) do
      @tracker = Tracker.new(FAKE_ACCOUNTS)
      Billing::BillingRecord.delete_all
    end

    after(:each) do
      Billing::BillingRecord.delete_all
    end

    describe '#update' do
      before(:each) do
        @resource = FAKE_AWS.servers.new
        @resource.stub(:tracker_account).and_return(FAKE_ACCOUNT)
        @resource.stub(:identity).and_return "fake server ID"
        @resource.stub(:status).and_return "running"
        FogTracker::AccountTracker.any_instance.stub(:all_resources).
          and_return([ @resource ])
      end

      it "Generates BillingRecords for all Resources in its accounts" do
        @tracker.update
        Billing::BillingRecord.all.count.should == 1
      end

      it "Generates billing codes for all Resources in its accounts" do
        @resource.stub(:tags).and_return('environment' => 'sandbox')
        @tracker.update
        @tracker['*::Compute::AWS::servers'].first.billing_codes.should ==
          [['environment', 'sandbox']]
      end
    end

  end
end
