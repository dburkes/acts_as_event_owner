require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :database => 'test.db'
})

require File.expand_path('../../lib/acts_as_event_owner', __FILE__)
include ActsAsEventOwner

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load(File.dirname(__FILE__) + '/schema.rb')
end

def clean_database!
  [ActsAsEventOwner::EventSpecification, ActsAsEventOwner::EventOccurrence].each do |model|
    ActiveRecord::Base.connection.execute "DELETE FROM #{model.table_name}"
  end
end

clean_database!