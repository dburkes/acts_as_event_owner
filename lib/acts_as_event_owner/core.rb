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
            def generate(options={})
              proxy_owner.event_specifications.each {|spec| spec.generate_events(options)}
              self.reload
            end
            
            def <<(obj)
              raise ActsAsEventOwner::Exception.new("Do not add events directly- add event specifications, then call events.generate")
            end
            
            def build(attributes={})
              raise ActsAsEventOwner::Exception.new("Do not build events directly- build event specifications, then call events.generate")
            end
            
            def create(attributes={})
              raise ActsAsEventOwner::Exception.new("Do not create events directly- build event specifications, then call events.generate")
            end
          end
        end
      end
    end

    module InstanceMethods
    end
  end
end
