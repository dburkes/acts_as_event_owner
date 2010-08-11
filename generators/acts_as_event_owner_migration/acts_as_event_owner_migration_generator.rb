class ActsAsEventOwnerMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "acts_as_event_owner_migration"
    end
  end
end