require 'acts_as_event_owner'

module ActsAsEventOwner
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      rake_tasks do
        puts Dir.pwd
        load "tasks/acts_as_event_owner_tasks.rake"
      end
    end
  end
end