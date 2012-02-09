module CloudCostTracker
  module Billing
    module Resources
      describe ResourceBillingPolicy do

        before(:each) do
          BillingRecord.delete_all
          @resource = FAKE_AWS.servers.new
          @default_policy = ResourceBillingPolicy.new
        end

        after(:each) do
          BillingRecord.delete_all
        end

        it "should expose a (null-impementation) setup method" do
          (Proc.new {@default_policy.setup}).should_not raise_error
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
              @default_policy.write_billing_record_for @resource
              BillingRecord.all.count.should == 0
            end
          end

          context 'when a matching record exists' do
            it "invokes update_from on the existing record" do
              existing_record = double "mock billing record"
              existing_record.stub(:overlaps_with).and_return true
              existing_record.stub(:id).and_return "existing fake record ID"
              BillingRecord.stub(:find_last_matching_record).
                and_return existing_record
              existing_record.should_receive :update_from
              @default_policy.write_billing_record_for @resource
            end
          end
          context 'when no matching record exists' do
            it "writes a new record" do
              BillingRecord.stub(:find_last_matching_record).and_return(nil)
              @default_policy.write_billing_record_for @resource
              results = BillingRecord.where(:resource_id => @resource.identity)
              results.should_not be_empty
              results.first.account.should == FAKE_ACCOUNT_NAME
              results.first.provider.should == 'AWS'
              results.first.service.should == 'Compute'
              results.first.billing_type.should == 'Server runtime'
            end
          end
        end

      end
    end
  end
end
