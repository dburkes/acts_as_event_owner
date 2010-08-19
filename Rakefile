require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.libs << 'lib'
  t.spec_files = FileList['spec/**/*.rb']
end

task :default => [:specs]
