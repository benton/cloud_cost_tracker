module CloudCostTracker
  module Coding
    module Resources
      describe ResourceCodingPolicy do

        before(:each) do
          @resource = FAKE_AWS.servers.new
          @default_policy = ResourceCodingPolicy.new
        end

        it "should expose a (null-impementation) setup method" do
          (Proc.new {@default_policy.setup}).should_not raise_error
        end

        describe '#code' do
          it 'should clear all billing codes the resource' do
            @default_policy.code(@resource)
            @resource.billing_codes.should == []
          end
        end

      end
    end
  end
end
