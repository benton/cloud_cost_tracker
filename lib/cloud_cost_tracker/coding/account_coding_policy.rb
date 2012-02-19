module CloudCostTracker
  module Coding
    # Implements the generic logic for attaching billing codes to all resources
    # in a single account.
    # Initializes the necessary ResourceCodingPolicy objects, sorts the
    # resources by policy, and calls {#code} once on each resource's policy,
    # to compute the billing codes as pairs of Strings.
    class AccountCodingPolicy

      # Creates an object that implements a coding policy
      # that attaches no billing codes
      # @param [Array <Fog::Model>] resources the resources to code
      # @param [Hash] options optional parameters:
      #  - :logger - a Ruby Logger-compatible object
      def initialize(resources, options={})
        @log = options[:logger] || FogTracker.default_logger
        setup_resource_coding_agents(resources)
      end

      # An initializer called by the framework once per bill coding cycle.
      # Override this method if you need to perform high-latency operations,
      # like network transactions, that should not be performed per-resource.
      def setup(resources) ; end

      # Defines the order in which resource collections are coded.
      # Override this method if you need to code the resource collections
      # in a particular order. Return an Array of the Fog::Model subclasses.
      # @return [Array <Class>] the class names, in preferred coding order
      def priority_classes ; Array.new end

      # Defines an acount-wide coding strategy for coding each resource.
      # Override this method if you need to write logic for attaching billing
      # codes to all resources in an account, regardless of collection / type.
      def attach_account_codes(resource) ; end

      # Defines the default method for coding all resources.
      # Attaches Billing Codes (String pairs) to resources, as @billing_codes.
      # Resources whose class is in {#priority_classes} are coded first.
      def code(resources)
        return if resources.empty?
        account = resources.first.tracker_account
        @log.info "Coding account #{account[:name]}"
        resources.each {|resource| attach_account_codes(resource)}
        classes_to_code = priority_classes + (@agents.keys - priority_classes)
        classes_to_code.delete_if {|res_class| @agents[res_class] == nil}
        classes_to_code.each do |fog_model_class|
          @log.info "Coding #{fog_model_class} in account #{account[:name]}"
          collection = resources.select {|r| r.class == fog_model_class}
          collection.each do |resource|
            @agents[fog_model_class].each do |agent|
              @log.debug "Coding #{resource.tracker_description}"
              agent.code(resource)
            end
          end
        end
      end

      private

      # Builds a Hash of CodingPolicy agents, indexed by resource Class name
      def setup_resource_coding_agents(resources)
        @agents = Hash.new
        ((resources.collect {|r| r.class}).uniq).each do |resource_class|
          @agents[resource_class] = CloudCostTracker::create_coding_agents(
            resource_class, {:logger => @log})
          @agents[resource_class].each {|agent| agent.setup(resources)}
          @agents.delete(resource_class) if @agents[resource_class].empty?
        end
      end

    end
  end
end
