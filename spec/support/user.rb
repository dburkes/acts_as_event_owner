class User < ActiveRecord::Base
  acts_as_event_owner
end
