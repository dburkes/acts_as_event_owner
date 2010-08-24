require 'rubygems'
require 'active_record'
require 'pp'

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :database => ':memory:'
})
# ActiveRecord::Base.logger = Logger.new(STDOUT)

require File.expand_path('../../lib/acts_as_event_owner', __FILE__)
include ActsAsEventOwner

require 'support/model_builders'
require 'support/user'

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load(File.dirname(__FILE__) + '/schema.rb')
end

def clean_database!
  [ActsAsEventOwner::EventSpecification, ActsAsEventOwner::EventOccurrence, User].each do |model|
    ActiveRecord::Base.connection.execute "DELETE FROM #{model.table_name}"
  end
end
