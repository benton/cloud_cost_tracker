# Implements a generic Billing Policy that always returns 0.0 cost
module CloudCostTracker
  module Billing
    class AccountBillingPolicy

      # Creates an object for billing Fog accounts
      #
      # ==== Attributes
      #
      # * +account_name+ - the name of the account to bill for
      # * +account+ - the Hash of account information (see accounts.yml.example)
      # * +options+ - Hash of optional parameters
      #
      # ==== Options
      #
      # * +:logger+ - a Ruby Logger-compatible object
      def initialize(account_name, account, options={})
        @account_name = account_name
        @account      = account
        @log          = options[:logger] || CloudCostTracker.default_logger
        @agents       = Hash.new  #
      end

      # Creates or Updates BillingRecords for an Array of +resources+
      def bill_resources(resources)
        @log.info "Generating costs for #{resources.count} "+
        "resources in account #{@account_name}"
        resources.each do |resource|
          if billing_agent = get_billing_agent(resource)
            bill_resource(resource, billing_agent)
          end
        end
      end

      private

      # Creates or Updates the BillingRecord for an individual +resource+
      # using the supplied +billing_agent+
      def bill_resource(resource, billing_agent)
        total = billing_agent.get_cost_since_time(resource, Time.now)
        if total < 0
          total = billing_agent.get_cost_for_duration(resource, 60)
        end
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
              @agents[billing_class_name] = policy_class.send(:new,
              @account_name, @account, { :logger => @log }
              )
            end
          end
        end
        @agents[billing_class_name]
      end

    end
  end
end
