module CloudCostTracker
  class BillingRecord < ActiveRecord::Base
    # Validations
    validates_presence_of :provider, :service, :account, :resource_id,
                          :resource_type, :start_time, :stop_time,
                          :cost_per_hour, :total_cost

    # Finds and returns the latest BillingRecord that "matches"
    # other_billing_record. The records must match all attributes
    # except start_time, stop_time, and total_cost
    # Note that if other_billing_record is in the database, this
    # method can return other_billing_record!
    # @param [BillingRecord] other_billing_record the record to match
    # @return [BillingRecord,nil] the latest "matching" BillingRecord
    def self.find_last_matching_record(other_billing_record)
      #if other_billing_record.resource_id =~ /e270/i
      #  puts "=========> Searching for previous record for #{other_billing_record.inspect}..."
      #end
      results = CloudCostTracker::BillingRecord.where(
        :provider       => other_billing_record.provider,
        :service        => other_billing_record.service,
        :account        => other_billing_record.account,
        :resource_id    => other_billing_record.resource_id,
        :resource_type  => other_billing_record.resource_type,
        :cost_per_hour  => other_billing_record.cost_per_hour,
      ).order(:stop_time).reverse_order.limit(1)
      #if other_billing_record.resource_id =~ /e270/i
      #  puts "=========> Found results #{results.inspect}..."
      #end
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
      #if resource_id =~ /e270/i
      #  puts "=========> #{second.start_time} - #{first.stop_time} <= #{min_proximity}"+
      #        " ??????  = #{second.start_time - first.stop_time <= min_proximity}"
      #end
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
