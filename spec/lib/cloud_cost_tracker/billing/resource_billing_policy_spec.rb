module CloudCostTracker
module Billing
describe ResourceBillingPolicy do

  before(:each) do
    BillingRecord.delete_all
    @resource = FAKE_AWS.servers.new
    @default_policy = ResourceBillingPolicy.new(:logger => LOG)
    @end_time = Time.now
    @start_time = @end_time - 3600   # one hour time span
  end

  after(:each) do
    BillingRecord.delete_all
  end

  it "should expose a (null-impementation) setup method" do
    (Proc.new {@default_policy.setup nil}).should_not raise_error
  end

  describe '#get_cost_for_duration' do
    it 'should always return a cost of 1, even with nil arguments' do
      @default_policy.get_cost_for_duration(nil, nil).should == 1.0
    end
  end

  describe '#write_billing_record_for' do
    before(:each) do
      @resource.stub(:tracker_account).and_return(FAKE_ACCOUNT)
      @resource.stub(:identity).and_return "fake server ID"
      @resource.stub(:status).and_return "running"
    end

    context "when it calculates a zero cost for a resource" do
      it "writes no billing record for the resource" do
        BillingRecord.all.count.should == 0
        @resource.stub(:status).and_return "stopped"
        # This next line is not *really* stubbing the tested behavior --
        # the default implementation of :get_cost_for_duration in
        # the subject class must be overriden to test its effects in
        # any implemented subclasses
        @default_policy.stub(:get_cost_for_duration).and_return 0
        @default_policy.write_billing_record_for(
          @resource, 0.0, 0.0, @start_time, @end_time)
        BillingRecord.all.count.should == 0
      end
    end

    context "when a record exists with the same resource and billing type" do
      before(:each) do
        @existing_record = BillingRecord.new(
          :provider       => FAKE_ACCOUNT[:provider],
          :service        => FAKE_ACCOUNT[:service],
          :account        => FAKE_ACCOUNT[:name],
          :resource_id    => @resource.identity,
          :resource_type  => 'Server',
          :billing_type   => "ResourceBillingPolicy",
          :start_time     => @start_time,
          :stop_time      => @end_time,
          :cost_per_hour  => 34.0,
          :total_cost     => 34.0
        )
        BillingRecord.stub(:most_recent_like).and_return @existing_record
      end
      context "when the records match in hourly cost and billing codes" do
        context "and they overlap in time" do
          it "invokes merge_with on the existing record" do
            @existing_record.should_receive(:merge_with)
            @default_policy.write_billing_record_for(
              @resource, 34.0, 34.0, @end_time, @end_time + 60)
          end
        end
      end
      context "when the new record differs in hourly rate or billing codes" do
        it "writes a new record starting at the existing record's stop time" do
          @existing_record.should_not_receive(:merge_with)
          @default_policy.write_billing_record_for(
            @resource, 5000000.0, 34.0, @end_time - 1, @end_time + 99)
          result = BillingRecord.where(:resource_id => @resource.identity).last
          result.start_time.to_s.should == @existing_record.stop_time.to_s
        end
      end
    end

    context 'with no existing record for the same resource and billing type' do
      it "writes a new record" do
        BillingRecord.stub(:find_last_matching_record).and_return(nil)
        @default_policy.write_billing_record_for(
          @resource, 0.0, 1.0, @start_time, @end_time)
        results = BillingRecord.where(:resource_id => @resource.identity)
        results.should_not be_empty
        results.first.account.should == FAKE_ACCOUNT_NAME
        results.first.provider.should == 'AWS'
        results.first.service.should == 'Compute'
        results.first.billing_type.should == 'ResourceBillingPolicy'
      end
    end
  end

end
end
end
