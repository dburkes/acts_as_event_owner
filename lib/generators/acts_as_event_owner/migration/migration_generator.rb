require 'rails/generators/migration'

module ActsAsEventOwner
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "Generates migration for EventSpecification and EventOcurrence models"

    def self.orm
      Rails::Generators.options[:rails][:orm]
    end

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', (orm.to_s unless orm.class.eql?(String)) )
    end

    def self.orm_has_migration?
      [:active_record].include? orm
    end

    def self.next_migration_number(path)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def create_migration_file
      if self.class.orm_has_migration?
        migration_template 'acts_as_event_owner_migration.rb', File.join('db', 'migrate', 'acts_as_event_owner_migration')
      end
    end
  end
end
