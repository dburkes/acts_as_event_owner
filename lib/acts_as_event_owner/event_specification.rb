require 'ri_cal'

module ActsAsEventOwner
  class EventSpecification < ::ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
    has_many :event_occurrences, :dependent => :destroy, :class_name => "::ActsAsEventOwner::EventOccurrence"

    serialize :repeat
    serialize :on
    serialize :on_the
    serialize :target

    ON_THE = { :first => '1', :second => '2', :third => '3', :fourth => '4', :last => '-1' }
    BYDAYS = { :day => 'SU,MO,TU,WE,TH,FR,SA', :wkday => 'MO,TU,WE,TH,FR', :wkend => 'SU,SA'}

    before_validation :set_defaults
    validates_presence_of :description
    validates_inclusion_of :repeat, :in => [:by_hour,:daily,:weekly,:monthly,:yearly], :allow_nil => true
    validates_inclusion_of :on_the, :in => ON_THE.keys, :allow_nil => true
    validates_numericality_of :frequency, :allow_nil => true
    validates_presence_of :start_at
    validate :validate_recurrence_rules
    after_validation :set_defaults_after_validation

    attr_accessor :generate
    after_create :auto_generate_events

    def validate_recurrence_rules
      case self.repeat
        when :by_hour
          errors.add(:target, "must be an array") if !self.target.present? || !self.target.is_a?(Array)
          [:on, :on_the].each {|v| errors.add(v, :present) if self.send(v)}

        when :daily
          [:on, :on_the, :target].each {|v| errors.add(v, :present) if self.send(v)}

        when :weekly
          errors.add(:on, "must be an array") if self.on.present? && !self.on.is_a?(Array)
          [:on_the, :target].each {|v| errors.add(v, :present) if self.send(v)}

        when :monthly
          if self.on_the
            errors.add(:target, "must be an array, :day, :wkday, or :wkend") if self.target.nil? || !(self.target.is_a?(Array) || BYDAYS.keys.include?(self.target))
            errors.add(:on, :present) if self.on.present?
          elsif self.on
            errors.add(:on, "must be an array") if !self.on.is_a?(Array)
            [:on_the, :target].each {|v| errors.add(v, :present) if self.send(v)}
          end

        when :yearly
          if self.on_the
            errors.add(:on, "must be an array") if !self.on.present? || !self.on.is_a?(Array)
            errors.add(:target, "must be an array, :day, :wkday, or :wkend") if self.target.nil? || !(self.target.is_a?(Array) || BYDAYS.keys.include?(self.target))
          elsif self.on
            errors.add(:on, "must be an array") if !self.on.present? || !self.on.is_a?(Array)
          else
            errors.add(:on, :present)
          end
      end
    end

    def to_rrule
      return nil if !self.valid? || self.repeat.nil?

      components = []
      repeat = self.repeat
      frequency = self.frequency

      case self.repeat
        when :by_hour
          repeat = "DAILY"
          components << "BYHOUR=#{self.target.join(',')}"
          frequency = nil

        when :daily

        when :weekly
          components << "BYDAY=#{self.on.join(',').upcase}" if self.on

        when :monthly
          if self.on_the
            components << "BYSETPOS=#{ON_THE[self.on_the]}"
            components << "BYDAY=#{byday}"
          end
          components << "BYMONTHDAY=#{self.on.join(',').upcase}" if self.on

        when :yearly
          components << "BYMONTH=#{self.on.join(',').upcase}" if self.on
          components << "BYSETPOS=#{ON_THE[self.on_the]};BYDAY=#{byday}" if self.on_the
      end

      components.unshift "INTERVAL=#{frequency}" if frequency
      components.unshift "FREQ=#{repeat.to_s.upcase}"
      components << "UNTIL=#{self.until.strftime("%Y%m%dT%H%M%S")}" if self.until
      components.join(';')
    end

    def generate_events options={}
      raise ActsAsEventOwner::Exception.new("Invalid Event Specification") if !valid?

      opts = options.clone
      opts[:from] ||= self.start_at
      opts[:to] ||= (opts[:from] + 30.days) if opts[:from]
      opts[:from] -= 1.second
      opts[:to] -= 1.second
      opts[:from] = opts[:to] = nil if opts[:count]
      attribute_overrides = opts[:attributes] || {}

      # puts "generate #{self.attributes.inspect} from #{opts[:from]} to #{opts[:to]} with #{attribute_overrides.inspect}"

      start_at = self.start_at
      end_at = self.end_at
      cal = RiCal.Calendar do |cal|
        cal.event do |event|
          event.description self.description
          event.dtstart(start_at) if start_at
          event.dtend(end_at) if end_at
          event.rrule = self.to_rrule if self.to_rrule
        end
      end
      event = cal.events.first
      # puts "event is #{event.inspect}"
      occurrences = event.occurrences(:starting => opts[:from], :before => opts[:to], :count => opts[:count])
      # puts "got #{occurrences.length} occurrences"
      occurrences.collect do |occurrence|
        @@OCCURRENCE_COLUMNS ||= (EventOccurrence.columns.collect(&:name) - EXCLUDED_COLUMNS)
        @@SPECIFICATION_COLUMNS ||= (EventSpecification.columns.collect(&:name) - EXCLUDED_COLUMNS)
        additional_columns = (@@SPECIFICATION_COLUMNS).inject({}) do |additional, column|
          additional[column] = self.attributes[column] if @@OCCURRENCE_COLUMNS.include?(column)
          additional
        end
        
        # puts "*********** #{occurrence.start_time} : #{occurrence.start_time.zone}"
        # puts "*********** #{Time.zone.at(occurrence.start_time.to_i)}"
        
        hash = {
          :owner_id => self.owner_id, :owner_type => self.owner_type, :event_specification_id => self.id,
          :description => occurrence.description, :start_at => occurrence.start_time.utc,
          :end_at => occurrence.finish_time.utc}.stringify_keys.merge(additional_columns).merge(attribute_overrides.stringify_keys)
          
        EventOccurrence.find_or_create_by_owner_id_and_owner_type_and_event_specification_id_and_start_at_and_end_at(hash)
      end
    end

    def self.generate_events options={}
      self.all(:conditions => "until IS NULL OR until >= '#{Time.zone.now.to_s(:db)}'").each {|spec|
        spec.generate_events(options)
      }
    end

    def repeat
      self.attributes["repeat"].try(:to_sym)
    end

    protected

    def set_defaults
      self.start_at ||= Time.zone.now
      self.end_at ||= self.start_at + 1.hour
      self.generate = { :from => self.start_at, :to => self.start_at + 30.days } if self.generate.nil?
    end

    def set_defaults_after_validation
      if self.errors.empty? && self.repeat == :by_hour
        current_start_hour = self.start_at.hour
        closest_repeat_hour = self.target.detect {|h| h > current_start_hour}
        if closest_repeat_hour
          self.start_at = Time.local(self.start_at.year, self.start_at.month, self.start_at.day, closest_repeat_hour)
        else
          tomorrow = self.start_at + 24.hours
          self.start_at = Time.local(tomorrow.year, tomorrow.month, tomorrow.day, self.target.first)
        end
      end
    end

    def byday
      self.target.is_a?(Array) ? self.target.join(',').upcase : BYDAYS[self.target]
    end

    def auto_generate_events
      self.generate_events(self.generate) if self.generate
      self.generate = nil
    end

    EXCLUDED_COLUMNS = [ "id", "owner_id", "owner_type", "description", "start_at", "end_at", "repeat", "frequency", "on", "on_the", "target", "until", "created_at", "updated_at" ]
  end
end