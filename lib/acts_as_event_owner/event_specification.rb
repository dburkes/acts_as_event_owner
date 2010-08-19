module ActsAsEventOwner
  class EventSpecification < ::ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
    has_many :event_occurrences, :dependent => :destroy
    
    serialize :repeat
    serialize :on
    serialize :on_the
    serialize :target
    
    ON_THE = { :first => '1', :second => '2', :third => '3', :fourth => '4', :last => '-1' }
    BYDAYS = { :day => 'SU,MO,TU,WE,TH,FR,SA', :wkday => 'MO,TU,WE,TH,FR', :wkend => 'SU,SA'}

    validates_inclusion_of :repeat, :in => [:daily,:weekly,:monthly,:yearly], :allow_nil => true
    validates_inclusion_of :on_the, :in => ON_THE.keys, :allow_nil => true
    validates_numericality_of :frequency, :allow_nil => true
    validate :validate_recurrence_rules
    
    def validate_recurrence_rules
      case self.repeat
        when nil
          valid = true
          
        when :daily
          valid = self.on.nil? && self.on_the.nil? && self.target.nil?
          
        when :weekly
          valid = (self.on.nil? || self.on.is_a?(Array)) && self.on_the.nil? && self.target.nil?
          
        when :monthly
          if self.on_the
            valid = self.target.present? && (self.target.is_a?(Array) || BYDAYS.keys.include?(self.target)) && self.on.nil?
          elsif self.on
            valid = self.on.is_a?(Array) && self.on_the.nil? && self.target.nil?
          else
            valid = true
          end
          
        when :yearly
          if self.on_the
            valid = self.on.present? && self.target.present? && (self.target.is_a?(Array) || BYDAYS.keys.include?(self.target))
          elsif self.on
            valid = self.on.is_a?(Array)
          else
            valid = false
          end
      end
      
      errors.add_to_base('Invalid recurrence specification') unless valid
    end
    
    def to_rrule
      return nil unless self.valid?
      
      case self.repeat
        when nil
          nil
          
        when :daily
          "FREQ=DAILY;INTERVAL=#{self.frequency}"
          
        when :weekly
          rr = "FREQ=WEEKLY;INTERVAL=#{self.frequency}"
          rr << ";BYDAY=#{self.on.join(',').upcase}" if self.on
          rr
          
        when :monthly
          rr = "FREQ=MONTHLY;INTERVAL=#{self.frequency}"
          rr << ";BYSETPOS=#{ON_THE[self.on_the]};BYDAY=#{byday}" if self.on_the
          rr << ";BYMONTHDAY=#{self.on.join(',').upcase}" if self.on
          rr
          
        when :yearly
          rr = "FREQ=YEARLY;INTERVAL=#{self.frequency}"
          rr << ";BYMONTH=#{self.on.join(',').upcase}" if self.on
          rr << ";BYSETPOS=#{ON_THE[self.on_the]};BYDAY=#{byday}" if self.on_the
          rr
      end
    end
    
    protected
    
    def byday
      self.target.is_a?(Array) ? self.target.join(',').upcase : BYDAYS[self.target]
    end
  end
end