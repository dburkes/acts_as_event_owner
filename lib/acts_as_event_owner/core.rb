module ActsAsEventOwner
  module Core
    def self.included(base)
      base.send :extend, ClassMethods
    end
  
    module ClassMethods
      def acts_as_event_owner options = {}
        include InstanceMethods

        class_eval do
          has_many :event_specifications, :class_name => ActsAsEventOwner::EventSpecification.name, :as => :owner, :dependent => :destroy
          has_many :events, :class_name => ActsAsEventOwner::EventOccurrence.name, :as => :owner, :readonly => true do
            def generate from, to
            end
          end
        end
      end
    end

    module InstanceMethods
    end
  end
end
