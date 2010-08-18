class ActsAsEventOwnerMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'acts_as_event_owner_migration.rb.erb', File.join('db', 'migrate'), :migration_file_name => "acts_as_event_owner_migration"
    end
  end
end