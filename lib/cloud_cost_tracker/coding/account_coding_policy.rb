# Defines the default order in which resources get "coded"
module CloudCostTracker
  module Coding
    class AccountCodingPolicy

      # Creates an object that implements a billing policy
      # that attaches no billing codes
      # @param [Array <Fog::Model>] resources the resources to code
      # @param [Hash] options optional parameters:
      #  - :logger - a Ruby Logger-compatible object
      def initialize(resources, options={})
        @log = options[:logger] || FogTracker.default_logger
        setup_resource_billing_agents(resources)
      end

      # Used by subclasses to perform setup each time an account's
      # resources are coded
      # High-latency operations like network transactions that are not
      # per-resource should be performed here
      def setup(resources) ; end

      # Defines the order in which resources are coded
      # @return [Array <Class>] the class names, in preferred coding order
      def priority_classes
        Array.new
      end

      # Attaches Billing Codes (String pairs) to resources, as billing_codes
      # Resources whose class is in priority_classes are coded first
      def code(resources)
        classes_to_code = priority_classes + (@agents.keys - priority_classes)
        classes_to_code.each do |fog_model_class|
          @log.debug "Coding class #{fog_model_class}"
          collection = resources.select {|r| r.class == fog_model_class}
          collection.each do |resource|
            @agents[fog_model_class].each {|agent| agent.code(resource)}
          end
        end
      end

      private
      
      # Builds a Hash of CodingPolicy agents, indexed by resource Class name
      def setup_resource_billing_agents(resources)
        @agents = Hash.new
        ((resources.collect {|r| r.class}).uniq).each do |resource_class|
          @agents[resource_class] = CloudCostTracker::create_coding_agents(
            resource_class, {:logger => @log})
          @agents[resource_class].each {|agent| agent.setup}
        end
      end

    end
  end
end
