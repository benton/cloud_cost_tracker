module CloudCostTracker
  module Extensions
    # Adds convenience methods to Fog::Model instances for tracking billing info
    module FogModel

      # an Array of pairs of Strings
      attr_accessor :billing_codes

    end
  end
end

module Fog
  class Model
    include CloudCostTracker::Extensions::FogModel
  end
end
