module CloudCostTracker
  class BillingRecord < ActiveRecord::Base

    has_and_belongs_to_many :billing_codes,
      :join_table => 'billing_records_codes'

    # Validations
    validates_presence_of :provider, :service, :account,
      :resource_id, :resource_type, :billing_type,
      :start_time, :stop_time, :cost_per_hour, :total_cost

    # Finds and returns the latest BillingRecord that "matches"
    # billing_record, or nil if none such exists.
    # The two records must match all their attributes except
    # start_time, stop_time, and total_cost.
    # Note that if billing_record is already in the database, this
    # method can return billing_record itself!
    # @param [BillingRecord] billing_record the record to match
    # @return [BillingRecord,nil] the latest "matching" BillingRecord
    def self.find_last_matching_record(billing_record)
      match = nil
      if most_recent =
        CloudCostTracker::BillingRecord.most_recent_like(billing_record)
        if (most_recent.cost_per_hour == billing_record.cost_per_hour)
          match = most_recent
        end
      end
      match
    end

    # Returns the most recent BillingRecord for the same resource as
    # the billing_record, or nil of there are none.
    # Note that if billing_record is already in the database, this
    # method can return billing_record itself!
    # @param [BillingRecord] other_billing_record the record to match
    # @return [BillingRecord,nil] the latest "matching" BillingRecord
    def self.most_recent_like(billing_record)
      results = CloudCostTracker::BillingRecord.where(
        :provider       => billing_record.provider,
        :service        => billing_record.service,
        :account        => billing_record.account,
        :resource_id    => billing_record.resource_id,
        :resource_type  => billing_record.resource_type,
        :billing_type  => billing_record.billing_type,
      ).order(:stop_time).reverse_order.limit(1)
      results.empty? ? nil : results.first
    end

    # Returns true if this BillingRecord's duration overlaps (inclusively)
    # with that of other_billing_record. The minimum amount of time that can be
    # between the records and still allow them to "overlap" can be increased
    def overlaps_with(other_billing_record, min_proximity = 0)
      return true if start_time == other_billing_record.start_time
      first, second = nil, nil  # Which record started first?
      if start_time < other_billing_record.start_time
        first, second = self, other_billing_record
      else
        first, second = other_billing_record, self
      end
      second.start_time - first.stop_time <= min_proximity
    end

    # Changes the stop time of this BillingRecord to be that of the
    # other_billing_record, then recalculates the total
    def update_from(other_billing_record)
      self.stop_time = other_billing_record.stop_time
      total = ((stop_time - start_time) * cost_per_hour) / 3600
      self.total_cost = total
      save!
    end

  end
end
