module CloudCostTracker
module Billing
describe BillingRecord do

  # some constants for a generic BillingRecord
  @stop_time  = Time.now
  @start_time = Time.now - FogTracker::DEFAULT_POLLING_TIME
  @hourly_rate = 5.0
  RECORD_PARAMETERS = {
    :provider       => "fake_provider_name",
    :service        => "fake_service_name",
    :account        => "fake_account_ID",
    :resource_id    => "fake_resource_ID",
    :resource_type  => "fake_resource_type",
    :billing_type   => "fake_billing_type",
    :start_time     => @start_time,
    :stop_time      => @stop_time,
    :cost_per_hour  => @hourly_rate,
    :total_cost     => ((@stop_time - @start_time) * @hourly_rate) / 3600,
  }
  # A day in the distant future
  NEW_YEARS_DAY_3000 = Time.gm(3000, 1, 1, 0, 0, 0)

  before(:each) do
    BillingRecord.delete_all ; BillingCode.delete_all   # clean database
    # Make a "current" billing record
    @existing_bill = BillingRecord.create!(RECORD_PARAMETERS)
    # Make a billing record that follows the existing one in time
    @next_bill = BillingRecord.new(RECORD_PARAMETERS.merge(
            :start_time => RECORD_PARAMETERS[:stop_time],
            :stop_time  => RECORD_PARAMETERS[:stop_time] + 3600
          ))
  end

  after(:each) do
    BillingRecord.delete_all ; BillingCode.delete_all   # clean database
  end

  it "is valid with valid attributes" do
    @existing_bill.should be_valid
  end

  it "is not valid without a provider name" do
    @existing_bill.provider = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without a service name" do
    @existing_bill.service = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without an account name" do
    @existing_bill.account = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without a resource ID" do
    @existing_bill.resource_id = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without a resource type" do
    @existing_bill.resource_type = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without a billing type" do
    @existing_bill.billing_type = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without a start time" do
    @existing_bill.start_time = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without a stop time" do
    @existing_bill.stop_time = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without an hourly cost" do
    @existing_bill.cost_per_hour = nil
    @existing_bill.should_not be_valid
  end
  it "is not valid without a total cost" do
    @existing_bill.total_cost = nil
    @existing_bill.should_not be_valid
  end
  it "validates its associated billing codes" do
    new_record = BillingRecord.new(RECORD_PARAMETERS)
    new_record.billing_codes = [BillingCode.new]
    new_record.should_not be_valid
  end

  describe '#most_recent_like' do
    context "when invoked with a BillingRecord" do
      context "and a record for the same resource / billing type exists" do
        it 'returns the most recent BillingRecord for the same resource' do
          BillingRecord.most_recent_like(@next_bill).should == @existing_bill
        end
      end
      context "and no record for the same resource / billing type exists" do
        it 'returns nil' do
          BillingRecord.delete_all
          BillingRecord.most_recent_like(@next_bill).should == nil
        end
      end
    end
  end

  describe '#overlaps_with' do
    context "when invoked with a BillingRecord far away in time" do
      it "returns false" do
        @next_bill.start_time = NEW_YEARS_DAY_3000
        @next_bill.stop_time  = NEW_YEARS_DAY_3000 + 3600
        @existing_bill.overlaps_with(@next_bill).should == false
      end

    end
    context "when invoked with a BillingRecord adjacent in time" do
      it "returns true" do
        @existing_bill.overlaps_with(@next_bill).should == true
      end
    end
    context "when invoked with a BillingRecord overlapping in time" do
      it "returns true" do
        @next_bill.start_time = RECORD_PARAMETERS[:stop_time] - 1
        @next_bill.stop_time  = RECORD_PARAMETERS[:stop_time] + 3600
        @existing_bill.overlaps_with(@next_bill).should == true
      end
    end
  end

  describe '#merge_with with an existing BillingRecord' do
    it "copies the stop time of the current record onto the existing record" do
      @next_bill.stop_time = NEW_YEARS_DAY_3000
      @existing_bill.merge_with @next_bill
      @existing_bill.stop_time.should == NEW_YEARS_DAY_3000
    end
    it "updates the total for the existing record" do
      # Run an update that causes the @existing_bill's total to double
      duration = (@existing_bill.stop_time - @existing_bill.start_time)
      @next_bill.stop_time = @existing_bill.stop_time + duration
      @existing_bill.merge_with @next_bill
      @existing_bill.total_cost.should == 2 * RECORD_PARAMETERS[:total_cost]
    end
  end

  describe '#set_codes' do
    context 'when invoked on a saved (existing) BillingRecord' do
      before(:each) {@existing_code = BillingCode.create!(:key=>'k', :value=>'v')}
      context "with a key, value pair that matches an existing BillingCode" do
        it "associates with the existing BillingCode" do
          @existing_bill.set_codes [['k', 'v']]
          @existing_bill.billing_codes.should == [@existing_code]
          @existing_bill.should be_valid
        end
      end
      context "with a key, value pair that matches no existing BillingCode" do
        it "creates a new BillingCode and associates with it" do
          @existing_bill.billing_codes.should == Array.new
          @existing_bill.set_codes [['k', 'v']]
          @existing_bill.billing_codes.should == [@existing_code]
          @existing_bill.should be_valid
        end
      end
    end
    context 'when invoked on a new, unsaved BillingRecord' do
      before(:each) { @new_bill = BillingRecord.new(RECORD_PARAMETERS) }
      context "with a key, value pair that matches an existing BillingCode" do
        it "associates with the existing BillingCode" do
          BillingCode.all.should == Array.new
          existing_code = BillingCode.create!(:key => 'k', :value => 'v')
          @new_bill.set_codes [['k', 'v']]
          @new_bill.billing_codes.should == [existing_code]
          @new_bill.should be_valid
        end
      end
      context "with a key, value pair that matches no existing BillingCode" do
        it "creates a new BillingCode and associates with it" do
          BillingCode.all.should == Array.new
          @new_bill.billing_codes.should == Array.new
          @new_bill.set_codes [['k', 'v']]
          @new_bill.billing_codes.size.should == 1
          @new_bill.billing_codes.first.key.should == 'k'
          @new_bill.billing_codes.first.value.should == 'v'
          @new_bill.should be_valid
        end
      end
    end
  end

  describe '#to_hash' do
    it "returns a Hash of the record's attributes" do
      @existing_bill.to_hash['provider'].should == "fake_provider_name"
      @existing_bill.to_hash['service'].should == "fake_service_name"
      @existing_bill.to_hash['account'].should == "fake_account_ID"
      @existing_bill.to_hash['resource_id'].should == "fake_resource_ID"
      @existing_bill.to_hash['resource_type'].should == "fake_resource_type"
      @existing_bill.to_hash['billing_type'].should == "fake_billing_type"
    end
  end

end
end
end
