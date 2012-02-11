module CloudCostTracker
  module Coding
    describe AccountCodingPolicy do

      before(:each) do
        @server = FAKE_AWS.servers.new
        @db = FAKE_RDS.servers.new
        @default_policy = AccountCodingPolicy.new([@server, @db])
      end

      describe '#setup' do
        it "does nothing in the default implementation" do
          (Proc.new {@default_policy.setup(nil)}).should_not raise_error
        end
      end

      describe '#priority_classes' do
        it "returns an empty Array in the default implementation" do
          @default_policy.priority_classes.should == Array.new
        end
      end

      describe '#code' do
        it 'attaches billing codes to tagged AWS resources' do
          @server.stub(:tags).and_return('environment' => 'sandbox')
          @default_policy.code([@server, @db])
          @server.billing_codes.should == [['environment', 'sandbox']]
        end
      end

    end
  end
end
