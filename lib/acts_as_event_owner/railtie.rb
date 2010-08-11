require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'acts_as_event_owner') if !defined?(ActsAsEventOwner)

module ActsAsEventOwner
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      config.after_initialize do
        ActsAsEventOwner::Railtie.insert
      end
      rake_tasks do
        load "tasks/acts_as_event_owner.rake"
      end
    end
  end

  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, ActsAsEventOwner)
    end
  end
end