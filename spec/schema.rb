ActiveRecord::Schema.define(:version => 1) do
  create_table "event_occurrences", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "event_specification_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "added_string"
    t.boolean  "added_boolean"
    t.datetime "added_datetime"
  end
  add_index "event_occurrences", ["event_specification_id"], :name => "index_event_occurrences_on_event_specification_id"
  add_index "event_occurrences", ["owner_id", "owner_type"], :name => "index_event_occurrences_on_owner_id_and_owner_type"

  create_table "event_specifications", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "repeat"
    t.integer  "frequency",         :default => 1
    t.string   "on"
    t.string   "on_the"
    t.string   "target"
    t.datetime "until"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "added_string"
    t.boolean  "added_boolean"
    t.datetime "added_datetime"
  end
  add_index "event_specifications", ["owner_id", "owner_type"], :name => "index_event_specifications_on_owner_id_and_owner_type"
  
  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end