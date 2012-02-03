module CloudCostTracker
  describe Tracker do

    before(:each) do
      @tracker = Tracker.new(FAKE_ACCOUNTS)
      BillingRecord.delete_all
    end

    after(:each) do
      BillingRecord.delete_all
    end

    describe '#update' do
      it "Generates BillingRecords for all Resources in its accounts" do
        resource = FAKE_AWS.servers.new
        resource.stub(:tracker_account).and_return(FAKE_ACCOUNT)
        resource.stub(:identity).and_return "fake server ID"
        resource.stub(:status).and_return "running"
        FogTracker::AccountTracker.any_instance.stub(:all_resources).
          and_return([ resource ])
        @tracker.update
        BillingRecord.all.count.should == 1
      end
    end

  end
end
