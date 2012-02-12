module CloudCostTracker
  class BillingCode < ActiveRecord::Base

    has_and_belongs_to_many :billing_records, 
      :join_table => 'billing_records_codes'

    # Validations
    validates_presence_of :key, :value

  end
end
