class CreateBillingRecords < ActiveRecord::Migration
  def self.up
    create_table :billing_records do |t|
      t.string :provider
      t.string :service
      t.string :account
      t.string :resource_id
      t.string :resource_type
      t.datetime :start_time
      t.datetime :stop_time
      t.float :cost_per_hour
      t.float :total_cost

      t.timestamps
    end
  end

  def self.down
    drop_table :billing_records
  end
end
