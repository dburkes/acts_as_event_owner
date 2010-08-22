require File.expand_path('../../spec_helper', __FILE__)

describe ActsAsEventOwner::EventSpecification do
  describe "defaults" do
    it "defaults start_time to now" do
      now = Time.now
      Time.stub!(:now).and_return(now)
      spec = new_event_specification
      spec.should be_valid
      spec.start_time.should == now
    end
    
    it "defaults duration to one hour" do
      spec = new_event_specification
      spec.should be_valid
      spec.end_time.should == spec.start_time + 1.hour
    end
    
    it "defaults repeat until forever" do
      spec = new_event_specification(:repeat => :daily)
      spec.until.should be_nil
    end
  end
  
  describe "validations" do
    it "requires a valid repeat interval" do
      new_event_specification(:repeat => :bogus).should_not be_valid
    end
  
    it "requires a description" do
      new_event_specification(:description => nil).should_not be_valid
    end
  end

  describe "non-recurring events" do
    it "passes validations" do
      new_event_specification.should be_valid
    end
    
    it "does not generate an RRULE" do
      new_event_specification.to_rrule.should be_nil
    end
  end
  
  describe "events recurring daily" do
    it "passes validations" do
      new_event_specification(:repeat => :daily).should be_valid
      new_event_specification(:repeat => :daily, :frequency => 4).should be_valid
    end
    
    it "does not support invalid recurrence specifications" do
      new_event_specification(:repeat => :daily, :frequency => 'foo').should_not be_valid
      new_event_specification(:repeat => :daily, :on => [1, 2]).should_not be_valid
      new_event_specification(:repeat => :daily, :on_the => :first).should_not be_valid
      new_event_specification(:repeat => :daily, :on_the => :first, :target => :wkday).should_not be_valid
    end

    it "defaults frequency to 1" do
      new_event_specification(:repeat => :daily).frequency.should == 1
    end
    
    it "generates an RRULE" do
      new_event_specification(:repeat => :daily).to_rrule.should == "FREQ=DAILY;INTERVAL=1"
      new_event_specification(:repeat => :daily, :frequency => 4).to_rrule.should == "FREQ=DAILY;INTERVAL=4"
    end
  end
  
  describe "events recurring weekly" do
    it "passes validations" do
      new_event_specification(:repeat => :weekly).should be_valid
      new_event_specification(:repeat => :weekly, :frequency => 2).should be_valid
      new_event_specification(:repeat => :weekly, :on => [:mo, :we, :fr]).should be_valid
    end
    
    it "does not support invalid recurrence specifications" do
      new_event_specification(:repeat => :weekly, :frequency => 'foo').should_not be_valid
      new_event_specification(:repeat => :weekly, :on_the => :first, :target => :wkend).should_not be_valid
      new_event_specification(:repeat => :weekly, :on => '2').should_not be_valid
    end
    
    it "generates an RRULE" do
      new_event_specification(:repeat => :weekly).to_rrule.should == "FREQ=WEEKLY;INTERVAL=1"
      new_event_specification(:repeat => :weekly, :frequency => 2).to_rrule.should == "FREQ=WEEKLY;INTERVAL=2"
      new_event_specification(:repeat => :weekly, :on => [:mo, :we, :fr]).to_rrule.should == "FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR"
    end
  end
  
  describe "events recurring monthly" do
    it "passes validations" do
      new_event_specification(:repeat => :monthly).should be_valid
      new_event_specification(:repeat => :monthly, :frequency => 2).should be_valid
      new_event_specification(:repeat => :monthly, :frequency => 2, :on => [1, 15, 20]).should be_valid
      new_event_specification(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => :wkday).should be_valid
      new_event_specification(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => [:mo, :we]).should be_valid
    end
    
    it "does not support invalid recurrence specification" do
      new_event_specification(:repeat => :monthly, :frequency => 'foo').should_not be_valid
      new_event_specification(:repeat => :monthly, :on => 2).should_not be_valid
      new_event_specification(:repeat => :monthly, :on => [2], :on_the => :first, :target => :wkday).should_not be_valid
      new_event_specification(:repeat => :monthly, :on_the => 2).should_not be_valid
      new_event_specification(:repeat => :monthly, :on_the => :first, :target => :we).should_not be_valid
      new_event_specification(:repeat => :monthly, :on_the => :first, :on => [2]).should_not be_valid
    end
    
    it "generates an RRULE" do
      new_event_specification(:repeat => :monthly).to_rrule.should == "FREQ=MONTHLY;INTERVAL=1"
      new_event_specification(:repeat => :monthly, :frequency => 2).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2"
      new_event_specification(:repeat => :monthly, :frequency => 2, :on => [1, 15, 20]).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2;BYMONTHDAY=1,15,20"
      new_event_specification(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => :wkday).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2;BYSETPOS=3;BYDAY=MO,TU,WE,TH,FR"
      new_event_specification(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => [:mo, :we]).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2;BYSETPOS=3;BYDAY=MO,WE"
    end
  end
  
  describe "events recurring yearly" do
    it "passes validations" do
      new_event_specification(:repeat => :yearly, :on => [1,7]).should be_valid
      new_event_specification(:repeat => :yearly, :frequency => 2, :on => [1,7]).should be_valid
      new_event_specification(:repeat => :yearly, :on => [1,7], :on_the => :first, :target => :wkend).should be_valid
    end
    
    it "does not support invalid recurrence rules" do
      new_event_specification(:repeat => :yearly).should_not be_valid
      new_event_specification(:repeat => :yearly, :frequency => 3).should_not be_valid
      new_event_specification(:repeat => :yearly, :frequency => 'foo').should_not be_valid
      new_event_specification(:repeat => :yearly, :on => 2).should_not be_valid
      new_event_specification(:repeat => :yearly, :on => [2], :on_the => 'first').should_not be_valid
      new_event_specification(:repeat => :yearly, :on => [2], :on_the => :first, :target => 2).should_not be_valid
    end
    
    it "generates an RRULE" do
      new_event_specification(:repeat => :yearly, :on => [1,7]).to_rrule.should == "FREQ=YEARLY;INTERVAL=1;BYMONTH=1,7"
      new_event_specification(:repeat => :yearly, :frequency => 2, :on => [1,7]).to_rrule.should == "FREQ=YEARLY;INTERVAL=2;BYMONTH=1,7"
      new_event_specification(:repeat => :yearly, :on => [1,7], :on_the => :first, :target => :wkend).to_rrule.should == "FREQ=YEARLY;INTERVAL=1;BYMONTH=1,7;BYSETPOS=1;BYDAY=SU,SA"
    end
  end
  
  describe "#generate_events" do
    before(:each) do
      @now = Time.now
      @bod = Date.today
      @walking_the_dog = create_event_specification :description => 'walk the dog', :start_time => @now, :repeat => :daily, :frequency => 1
    end
    
    it "generates a single event for a non-recurring event specification" do
      es = create_event_specification :start_time => @now
      lambda {
        es.generate_events :from => @bod
      }.should change(EventOccurrence, :count).by(1)
    end
    
    it "generates recurring events according to the rrule" do
      lambda {
        @walking_the_dog.generate_events :from => @bod, :to => @bod + 1.week
      }.should change(EventOccurrence, :count).by(7)
    end
    
    it "does not generate events before the specified :from" do
      lambda {
        @walking_the_dog.generate_events :from => @bod + 1.day, :to => @bod + 1.week
      }.should change(EventOccurrence, :count).by(6)
    end
    
    it "does not generate events after the specified :to" do
      lambda {
        @walking_the_dog.generate_events :from => @bod + 1.day, :to => @bod + 6.days
      }.should change(EventOccurrence, :count).by(5)
    end
    
    it "does not generate more events than the specified :count" do
      lambda {
        @walking_the_dog.generate_events :from => @bod, :to => @bod + 1.week, :count => 3
      }.should change(EventOccurrence, :count).by(3)
    end
    
    it "returns the new events" do
      events = @walking_the_dog.generate_events :from => @bod, :to => @bod + 1.week
      events.should be_present
      events.first.class.should == EventOccurrence
    end
    
    it "returns but does not persist duplicate events" do
      lambda {
        @walking_the_dog.generate_events :from => @bod, :to => @bod + 1.week
      }.should change(EventOccurrence, :count).by(7)
      
      lambda {
        events = @walking_the_dog.generate_events :from => @bod, :to => @bod + 1.week
        events.should be_present
        events.size.should == 7
      }.should_not change(EventOccurrence, :count)
    end
    
    it "raises an exception if the event specification is invalid" do
      spec = new_event_specification(:description => nil)
      spec.should_not be_valid
      lambda {
        spec.generate_events :from => @bod
      }.should raise_error(ActsAsEventOwner::Exception)
    end
    
    it "does not generate events for specification that are past their end_time" do
      @walking_the_dog.update_attributes! :start_time => @now - 1.week, :until => @now - 2.days
      lambda {
        @walking_the_dog.generate_events :from => @bod, :to => @bod + 1.week
      }.should_not change(EventOccurrence, :count)
    end
  end
end
