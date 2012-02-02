require 'active_record'
require 'logger'

# Load ResourceBillingPolicy class
require 'cloud_cost_tracker/billing/resources/resource_billing_policy'
# Load all ruby files from 'cloud_cost_tracker' directory
Dir[File.join(File.dirname(__FILE__), "cloud_cost_tracker/**/*.rb")].each {|f| require f}

module CloudCostTracker

  # Creates and returns an appropriate instance of ResourceBillingPolicy
  # for billing the given +resource+, or nil the Class is not found
  # @param [Class] resource_class the Class object for the billed resource
  # @param [Hash] options optional additional parameters:
  #  - :logger - a Ruby Logger-compatible object
  # @return [ResourceBillingPolicy] a billing policy object for resource
  def self.create_billing_agent(resource_class, options = {})
    agent = nil
    # Safely descend through the Billing module Heirarchy
    if matches = resource_class.name.match(%r{^Fog::(\w+)::(\w+)::(\w+)})
      fog_svc, provider, policy_name =
        matches[1], matches[2], "#{matches[3]}BillingPolicy"
      if CloudCostTracker::Billing::Resources.const_defined? fog_svc
        service_module = CloudCostTracker::Billing::Resources::const_get fog_svc
        if service_module.const_defined? provider
          provider_module = service_module.const_get provider
          if provider_module.const_defined? policy_name
            policy_class = provider_module.const_get policy_name
            agent = policy_class.new(:logger => options[:logger])
          end
        end
      end
    end
    agent
  end

end
