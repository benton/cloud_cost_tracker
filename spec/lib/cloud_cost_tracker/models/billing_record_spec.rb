module CloudCostTracker
  describe BillingRecord do
    before(:each) do

      @stop_time  = Time.now
      @start_time = Time.now - FogTracker::DEFAULT_POLLING_TIME
      @hourly_rate = 5.0
      @existing_bill_params = {
        :provider       => "fake_provider_name",
        :service        => "fake_service_name",
        :account        => "fake_account_ID",
        :resource_id    => "fake_resource_ID",
        :resource_type  => "fake_resource_type",
        :start_time     => @start_time,
        :stop_time      => @stop_time,
        :cost_per_hour  => @hourly_rate,
        :total_cost     => ((@stop_time - @start_time) * @hourly_rate) / 3600,
      }
      @existing_bill = BillingRecord.create!(@existing_bill_params)
       @new_years_day_2100 = Time.gm(2100, 1, 1, 0, 0, 0)
    end

    after(:each) do
      @existing_bill.destroy
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

    describe '#find_last_matching_record' do
      context "when a matching record exists" do
        it "Finds and returns the most recent 'matching' BillingRecord" do
          BillingRecord.find_last_matching_record(@existing_bill).
            should == @existing_bill
        end
      end
      context "when non-matching records exist" do
        it "returns nil" do
          new_bill = BillingRecord.new(@existing_bill_params.merge(
            :service => 'some other service'
          ))
          BillingRecord.find_last_matching_record(new_bill).
            should == nil
        end
      end
      context "when no records exist" do
        it "returns nil" do
          new_bill = BillingRecord.new(@existing_bill_params)
          BillingRecord.delete_all
          BillingRecord.find_last_matching_record(new_bill).
            should == nil
        end
      end
    end

    describe '#overlaps_with' do
      context "when invoked with a BillingRecord far away in time" do
        it "returns false" do
          new_bill = BillingRecord.new(@existing_bill_params.merge(
            :start_time => @new_years_day_2100,
            :stop_time  => @new_years_day_2100 + 3600
          ))
          @existing_bill.overlaps_with(new_bill).should == false
        end

      end
      context "when invoked with a BillingRecord adjacent in time" do
        it "returns true" do
          new_bill = BillingRecord.new(@existing_bill_params.merge(
            :start_time => @existing_bill_params[:stop_time],
            :stop_time  => @existing_bill_params[:stop_time] + 3600
          ))
          @existing_bill.overlaps_with(new_bill).should == true
        end
      end
      context "when invoked with a BillingRecord overlapping in time" do
        it "returns true" do
          new_bill = BillingRecord.new(@existing_bill_params.merge(
            :start_time => @existing_bill_params[:stop_time] - 1,
            :stop_time  => @existing_bill_params[:stop_time] + 3600
          ))
          @existing_bill.overlaps_with(new_bill).should == true
        end
      end
    end

    describe '#update_from with an existing BillingRecord' do
      it "copies the stop time of the current record onto the existing record" do
        new_bill = BillingRecord.new(@existing_bill_params.merge(
          :stop_time => @new_years_day_2100
        ))
        @existing_bill.update_from new_bill
        @existing_bill.stop_time.should == @new_years_day_2100
      end
      it "updates the total for the existing record" do
        # Run an update that causes the @existing_bill's total to double
        duration = (@existing_bill.stop_time - @existing_bill.start_time)
        new_bill = BillingRecord.new(@existing_bill_params.merge(
          :stop_time => @existing_bill.stop_time + duration
        ))
        @existing_bill.update_from new_bill
        @existing_bill.total_cost.should == 2 * @existing_bill_params[:total_cost]
      end
    end

  end
end
