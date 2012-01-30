# Implements a class for managing a Resource's BillingRecord
module CloudCostTracker
  module Billing
    class ResourceBiller

      # Creates an object for managing a resource's BillingRecords
      # @param [Fog::Model] the Fog resource whose BillingRecord should be
      #    created or updated.
      # @param [Hash] options optional additional parameters:
      #  - :logger - a Ruby Logger-compatible object
      def initialize(resource, options={})
        @resource = resource
        @log      = options[:logger] || FogTracker.default_logger
        if billing_agent = get_billing_agent(resource)
          bill_resource(resource, billing_agent)
        end
      end

      private

      # Creates or Updates the BillingRecord for an individual +resource+
      # using the supplied +billing_agent+
      def bill_resource(resource, billing_agent)
        total = billing_agent.get_cost_since_time(resource, Time.now)
        total ||= billing_agent.get_cost_for_duration(resource, 60)
        @log.debug "Generated cost #{total} for #{resource.class} "+
        "#{resource.identity}"
      end

      # Returns an appropriate instance of ResourceBillingPolicy
      # for the given +resource+, or nil the Class is not found
      def get_billing_agent(resource)
        @agents ||= Hash.new # Remeber BillingPolicy instances, indexed by class
        billing_class_name = "CloudCostTracker::Billing::Resources"
        if matches = resource.class.name.match(%r{^Fog::(\w+)::(\w+)::(\w+)})
          fog_svc, provider, policy_name =
            matches[1], matches[2], "#{matches[3]}BillingPolicy"
          billing_class_name += "::#{fog_svc}::#{provider}::#{policy_name}"
          if not @agents[billing_class_name]
            service_module =
              CloudCostTracker::Billing::Resources::const_get fog_svc
            provider_module = service_module.send(:const_get, provider)
            if provider_module.send(:const_defined?, policy_name)
              @log.debug "Creating Billing Agent #{billing_class_name}"
              policy_class = provider_module.send(:const_get, policy_name)
              @agents[billing_class_name] =
                policy_class.send(:new, {:logger => @log})
            end
          end
        end
        @agents[billing_class_name]
      end

    end
  end
end
