class CreateBillingCodes < ActiveRecord::Migration
  def self.up
    create_table :billing_codes do |t|
      t.string :key,    :size => 512, :null => false
      t.string :value,  :size => 512
    end

    create_table :billing_records_codes, :id => false do |t|
      t.integer :billing_record_id, :null => false
      t.integer :billing_code_id,   :null => false
    end

  end

  def self.down
    drop_table :billing_codes
    drop_table :billing_records_codes
  end

end
