require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.libs << 'lib'
  t.spec_files = FileList['spec/**/*.rb']
end

task :default => [:specs]

begin
  require 'jeweler'
  require 'lib/acts_as_event_owner'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "acts_as_event_owner"
    gemspec.version = ActsAsEventOwner::VERSION
    gemspec.summary = "Simple calendar events for any ActiveRecord model"
    gemspec.email = "dburkes@netable.com"
    gemspec.homepage = "http://github.com/dburkes/acts_as_event_owner"
    gemspec.description = "Simple calendar events for any ActiveRecord model"
    gemspec.authors = ["Danny Burkes"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
