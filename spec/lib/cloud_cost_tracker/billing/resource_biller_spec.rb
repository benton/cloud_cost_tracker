module CloudCostTracker
  module Billing
    describe ResourceBiller do

      before(:each) do
        @resource = Fog::Compute[:aws].servers.new
        @biller = ResourceBiller.new(@resource)
      end

    end
  end
end
