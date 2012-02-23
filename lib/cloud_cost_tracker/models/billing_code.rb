module CloudCostTracker
  module Billing
    class BillingCode < ActiveRecord::Base

      has_and_belongs_to_many :billing_records,
        :join_table => 'billing_records_codes'

      # Validations
      validates :key,   :presence => true
      validates :value, :uniqueness => {:scope => :key}

    end
  end
end
