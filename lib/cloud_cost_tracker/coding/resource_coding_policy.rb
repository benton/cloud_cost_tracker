# Abstract class, defines a generic resource Coding Policy that attaches no codes
module CloudCostTracker
  module Coding
    class ResourceCodingPolicy

      # Creates an object that implements a billing policy
      # that attaches no billing codes
      # @param [Hash] options optional parameters:
      #  - :logger - a Ruby Logger-compatible object
      def initialize(options={})
        @log = options[:logger] || FogTracker.default_logger
      end

      # Used by subclasses to perform setup each time an account's
      # resources are coded
      # High-latency operations like network transactions that are not
      # per-resource should be performed here
      def setup(resources) ; end

      # Attaches Billing Codes (String pairs) to resource, as billing_codes
      def code(resource) ; end

    end
  end
end
