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
          it 'should always return zero cost, even with nil arguments' do
            @default_policy.get_cost_for_duration(nil, nil).should == 0.0
          end
        end

        describe '#write_billing_record_for' do
          context 'when a matching record exists' do
            it "calls update_from on the existing record with the new record" do
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
            it "writes a new record with the resource data" do
              BillingRecord.stub(:find_last_matching_record).and_return(nil)
              @resource.stub(:tracker_account).and_return({
                :name => 'fake account name', :provider => 'fake provider',
                :service => 'fake service'
              })
              @resource.stub(:identity).and_return "fake server ID"
              @default_policy.write_billing_record_for @resource
              results = BillingRecord.where(:resource_id => @resource.identity)
              results.should_not be_empty
              results.first.account.should == 'fake account name'
              results.first.provider.should == 'fake provider'
              results.first.service.should == 'fake service'
            end
          end
        end

      end
    end
  end
end
