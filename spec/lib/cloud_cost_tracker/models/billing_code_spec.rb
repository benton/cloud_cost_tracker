module CloudCostTracker
  describe BillingCode do
    before(:each) do
      @existing_code = BillingCode.create!(
        :key => 'fake key', :value => 'fake value'
      )
    end

    after(:each) do
      @existing_code.destroy
    end

    it "is valid with valid attributes" do
      @existing_code.should be_valid
    end

    it "is not valid without a key" do
      @existing_code.key = nil
      @existing_code.should_not be_valid
    end
    it "is not valid without a value" do
      @existing_code.value = nil
      @existing_code.should_not be_valid
    end

  end
end
