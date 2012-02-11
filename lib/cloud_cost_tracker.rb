require 'active_record'
require 'logger'

# Load generic ResourceBillingPolicy and Coding classes
require 'cloud_cost_tracker/billing/resource_billing_policy'
require 'cloud_cost_tracker/coding/resource_coding_policy'
# Load all ruby files from 'cloud_cost_tracker' directory
Dir[File.join(File.dirname(__FILE__), "cloud_cost_tracker/**/*.rb")].each {|f| require f}

module CloudCostTracker

  # Creates and returns an Array of ResourceBillingPolicy (subclass) instances
  # for billing the given +resource+, or an empty Array of none are found
  # @param [Class] resource_class the Class object for the billed resource
  # @param [Hash] options optional additional parameters:
  #  - :logger - a Ruby Logger-compatible object
  # @return [Array <ResourceBillingPolicy>] billing policy objects for resource
  def self.create_billing_agents(resource_class, options = {})
    agents = Array.new
    # Safely descend through the Billing module Heirarchy
    if matches = resource_class.name.match(%r{^Fog::(\w+)::(\w+)::(\w+)})
      fog_svc, provider, model_name = matches[1], matches[2], matches[3]
      if CloudCostTracker::Billing.const_defined? fog_svc
        service_module = CloudCostTracker::Billing::const_get fog_svc
        if service_module.const_defined? provider
          provider_module = service_module.const_get provider
          # Search through the classes in the module for all matches
          classes = provider_module.classes.each do |policy_class|
            if policy_class.name =~ /#{model_name}.*BillingPolicy/
              agents << policy_class.new(:logger => options[:logger])
            end
          end
        end
      end
    end
    agents
  end

  # Creates and returns an Array of ResourceCodingPolicy (subclass) instances
  # for coding the given +resource+, or an empty Array of none are found
  # @param [Class] resource_class the Class object for the billed resource
  # @param [Hash] options optional additional parameters:
  #  - :logger - a Ruby Logger-compatible object
  # @return [Array <ResourceCodingPolicy>] coding policy objects for resource
  def self.create_coding_agents(resource_class, options = {})
    agents = Array.new
    # Safely descend through the Coding module Heirarchy
    if matches = resource_class.name.match(%r{^Fog::(\w+)::(\w+)::(\w+)})
      fog_svc, provider, model_name = matches[1], matches[2], matches[3]
      if CloudCostTracker::Coding.const_defined? fog_svc
        service_module = CloudCostTracker::Coding::const_get fog_svc
        if service_module.const_defined? provider
          provider_module = service_module.const_get provider
          # Search through the classes in the module for all matches
          classes = provider_module.classes.each do |policy_class|
            if policy_class.name =~ /#{model_name}.*CodingPolicy/
              agents << policy_class.new(:logger => options[:logger])
            end
          end
        end
      end
    end
    agents
  end

end
