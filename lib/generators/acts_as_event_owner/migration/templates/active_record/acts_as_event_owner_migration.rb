class ActsAsEventOwnerMigration < ActiveRecord::Migration
  def self.up
    create_table :event_specifications do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :description
      t.string :event_type
      t.string :notification_type
      t.datetime :start_time
      t.datetime :end_time
      t.string :repeat                         # daily, weekly, monthly, yearly
      t.integer :frequency, :default => 1      # every 'n' days, weeks, months, or years
      t.string :on                             # su, mo, tu, we, th, fr, sa, 1-31, jan-dec
      t.string :on_the                         # first, second, third, fourth, last
      t.string :target                         # su, mo, tu, we, th, fr, sa, day, wkday, wkend
      t.timestamps
    end

    add_index :event_specifications, [:owner_id, :owner_type]

    create_table :event_occurrences do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :event_specification_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :description
      t.string :event_type
      t.string :notification_type
      t.timestamps
    end

    add_index :event_occurrences, [:owner_id, :owner_type]
    add_index :event_occurrences, :event_specification_id
  end

  def self.down
    drop_table :event_specifications
    drop_table :event_occurrences
  end
end