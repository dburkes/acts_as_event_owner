namespace :acts_as_event_owner do
  desc "Generate all events within a certain time window"
  task :generate_events do
    puts "Set FROM to something parseable by Time.parse" and return if !ENV['FROM']
    puts "Set TO to something parseable by Time.parse" and return if !ENV['TO']
    ActsAsEventOwner::EventSpecification.all(:conditions => "until IS NULL OR until >= '#{Time.now.utc.to_s(:db)}'").each {|spec| spec.generate_events(options)}
  end
end