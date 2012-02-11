module CloudCostTracker
  module Extensions
    # Adds convenience methods to Fog::Model instances for tracking billing info
    module FogModel

      # Adds a billing code to this cloud computing resource
      # (Has no effect if the identical key is alreay set)
      # @param [String] key the key for the desired billing code
      # @param [String] value the value for the desired billing code
      def code(key, value)
        @_billng_codes ||= Array.new
        if not @_billng_codes.include?([key, value])
          @_billng_codes.push [key, value]
        end
      end

      # Adds a billing code to this cloud computing resource
      # (Has no effect if the identical key is alreay set)
      # @param [String] key the key for the desired billing code
      # @param [String] value the value for the desired billing code
      def remove_code(key, value)
        @_billng_codes ||= Array.new
        @_billng_codes.delete [key, value]
      end

      # Returns this resource's billing codes
      # @return [Array [<String>, <String>]]
      def billing_codes
        @_billng_codes ||= Array.new
        @_billng_codes
      end

    end
  end
end

module Fog
  class Model
    include CloudCostTracker::Extensions::FogModel
  end
end
