require File.join(File.dirname(__FILE__), 'acts_as_event_owner/version')
require File.join(File.dirname(__FILE__), 'acts_as_event_owner/event_specification')
require File.join(File.dirname(__FILE__), 'acts_as_event_owner/event_occurrence')
require File.join(File.dirname(__FILE__), 'acts_as_event_owner/railtie')

module ActsAsEventOwner
  module ClassMethods
    def acts_as_event_owner options = {}
      include InstanceMethods

      class_eval do
        has_many :event_specifications, :class_name => ActsAsEventOwner::EventSpecification.name, :as => :owner, :dependent => :destroy
        has_many :events, :class_name => ActsAsEventOwner::EventOccurrence.name, :as => :owner
      end
    end
  end

  module InstanceMethods
  end
end