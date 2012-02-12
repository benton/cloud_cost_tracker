class CreateBillingCodes < ActiveRecord::Migration
  def self.up
    create_table :billing_codes do |t|
      t.string :key
      t.string :value
    end

    create_table :billing_records_codes do |t|
      t.integer :billing_record_id
      t.integer :billing_code_id
    end

  end

  def self.down
    drop_table :billing_codes
    drop_table :billing_records_codes
  end

end
