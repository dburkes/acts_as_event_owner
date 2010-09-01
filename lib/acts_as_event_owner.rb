require 'rubygems'
require 'active_record'

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'acts_as_event_owner/core'
require 'acts_as_event_owner/event_specification'
require 'acts_as_event_owner/event_occurrence'
require 'acts_as_event_owner/exception'
require 'acts_as_event_owner/railtie'
require 'acts_as_event_owner/version'

$LOAD_PATH.shift

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, ActsAsEventOwner::Core
end
