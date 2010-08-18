module ActsAsEventOwner
  class EventSpecification < ::ActiveRecord::Base
    belongs_to :owner, :polymorphic => true
    has_many :event_occurrences, :dependent => :destroy
    
    serialize :repeat
    serialize :on
    serialize :on_the
    serialize :target
    
    validates_inclusion_of :repeat, :in => [:daily,:weekly,:monthly,:yearly], :allow_nil => true
    validates_numericality_of :frequency, :allow_nil => true
    
    def validate
      true
    end
    
    def to_rrule
      case self.repeat
        when nil
          nil
          
        when :daily
          "FREQ=DAILY;INTERVAL=#{self.frequency}"
          
        when :weekly
          "FREQ=WEEKLY;INTERVAL=#{self.frequency};BYDAY=#{self.on.join(',').upcase}"
          
        when :monthly
          if self.on_the
            "FREQ=MONTHLY;INTERVAL=#{self.frequency};BYSETPOS=#{ON_THE[self.on_the]};BYDAY=#{BYDAYS[self.target]}"
          elsif self.on
            "FREQ=MONTHLY;INTERVAL=#{self.frequency};BYMONTHDAY=#{self.on.join(',').upcase}"
          else
            "FREQ=MONTHLY;INTERVAL=#{self.frequency}"
          end
          
        when :yearly
      end
    end
    
    protected
    
    ON_THE = { :first => '1', :second => '2', :third => '3', :fourth => '4', :last => '-1' }
    BYDAYS = { :day => 'SU,MO,TU,WE,TH,FR,SA', :wkday => 'MO,TU,WE,TH,FR', :wkend => 'SU,SA'}
  end
end