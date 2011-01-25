namespace :acts_as_event_owner do
  task :require_from do
    raise "Set FROM to something understandable by Time.parse" if !ENV['FROM']
  end

  task :require_to do
    raise "Set TO to something understandable by Time.parse" if !ENV['TO']
  end

  desc "Generate all events within a certain time window"
  task :generate_events => [:environment, :require_from, :require_to] do
    ActsAsEventOwner::EventSpecification.all(:conditions => "until IS NULL OR until >= '#{Time.zone.now.to_s(:db)}'").each {|spec| spec.generate_events(options)}
  end
end