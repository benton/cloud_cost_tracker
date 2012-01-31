require 'active_record'
require 'logger'

# Load ResourceBillingPolicy class
require 'cloud_cost_tracker/billing/resources/resource_billing_policy'
# Load all ruby files from 'cloud_cost_tracker' directory
Dir[File.join(File.dirname(__FILE__), "cloud_cost_tracker/**/*.rb")].each {|f| require f}

module CloudCostTracker

  # Creates and returns an appropriate instance of ResourceBillingPolicy
  # for billing the given +resource+, or nil the Class is not found
  # @param [Fog::Model] resource the resource for which to generate a bill
  # @param [Hash] options optional additional parameters:
  #  - :logger - a Ruby Logger-compatible object
  # @return [ResourceBillingPolicy] a billing policy object for resource
  def self.create_billing_agent(resource, options = {})
    agent = nil
    billing_class_name = "CloudCostTracker::Billing::Resources"
    if matches = resource.class.name.match(%r{^Fog::(\w+)::(\w+)::(\w+)})
      fog_svc, provider, policy_name =
        matches[1], matches[2], "#{matches[3]}BillingPolicy"
      billing_class_name += "::#{fog_svc}::#{provider}::#{policy_name}"
      service_module =
        CloudCostTracker::Billing::Resources::const_get fog_svc
      provider_module = service_module.send(:const_get, provider)
      if provider_module.send(:const_defined?, policy_name)
        policy_class = provider_module.send(:const_get, policy_name)
        agent = policy_class.send(:new, resource, {:logger => options[:logger]})
      end
    end
    agent
  end

end
