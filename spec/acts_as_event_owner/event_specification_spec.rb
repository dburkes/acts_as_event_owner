require File.expand_path('../../spec_helper', __FILE__)

describe ActsAsEventOwner::EventSpecification do
  it "requires a valid repeat interval" do
    EventSpecification.new(:repeat => :bogus).should_not be_valid
  end

  describe "non-recurring events" do
    it "passes validations" do
      EventSpecification.new.should be_valid
    end
    
    it "does not generate an RRULE" do
      EventSpecification.new.to_rrule.should be_nil
    end
  end
  
  describe "events recurring daily" do
    it "passes validations" do
      EventSpecification.new(:repeat => :daily).should be_valid
      EventSpecification.new(:repeat => :daily, :frequency => 4).should be_valid
    end
    
    it "does not support invalid recurrence specifications" do
      EventSpecification.new(:repeat => :daily, :frequency => 'foo').should_not be_valid
      EventSpecification.new(:repeat => :daily, :on => [1, 2]).should_not be_valid
      EventSpecification.new(:repeat => :daily, :on_the => :first).should_not be_valid
      EventSpecification.new(:repeat => :daily, :on_the => :first, :target => :wkday).should_not be_valid
    end

    it "defaults frequency to 1" do
      EventSpecification.new(:repeat => :daily).frequency.should == 1
    end
    
    it "generates an RRULE" do
      EventSpecification.new(:repeat => :daily).to_rrule.should == "FREQ=DAILY;INTERVAL=1"
      EventSpecification.new(:repeat => :daily, :frequency => 4).to_rrule.should == "FREQ=DAILY;INTERVAL=4"
    end
  end
  
  describe "events recurring weekly" do
    it "passes validations" do
      EventSpecification.new(:repeat => :weekly).should be_valid
      EventSpecification.new(:repeat => :weekly, :frequency => 2).should be_valid
      EventSpecification.new(:repeat => :weekly, :on => [:mo, :we, :fr]).should be_valid
    end
    
    it "does not support invalid recurrence specifications" do
      EventSpecification.new(:repeat => :weekly, :frequency => 'foo').should_not be_valid
      EventSpecification.new(:repeat => :weekly, :on_the => :first, :target => :wkend).should_not be_valid
      EventSpecification.new(:repeat => :weekly, :on => '2').should_not be_valid
    end
    
    it "generates an RRULE" do
      EventSpecification.new(:repeat => :weekly).to_rrule.should == "FREQ=WEEKLY;INTERVAL=1"
      EventSpecification.new(:repeat => :weekly, :frequency => 2).to_rrule.should == "FREQ=WEEKLY;INTERVAL=2"
      EventSpecification.new(:repeat => :weekly, :on => [:mo, :we, :fr]).to_rrule.should == "FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR"
    end
  end
  
  describe "events recurring monthly" do
    it "passes validations" do
      EventSpecification.new(:repeat => :monthly).should be_valid
      EventSpecification.new(:repeat => :monthly, :frequency => 2).should be_valid
      EventSpecification.new(:repeat => :monthly, :frequency => 2, :on => [1, 15, 20]).should be_valid
      EventSpecification.new(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => :wkday).should be_valid
      EventSpecification.new(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => [:mo, :we]).should be_valid
    end
    
    it "does not support invalid recurrence specification" do
      EventSpecification.new(:repeat => :monthly, :frequency => 'foo').should_not be_valid
      EventSpecification.new(:repeat => :monthly, :on => 2).should_not be_valid
      EventSpecification.new(:repeat => :monthly, :on => [2], :on_the => :first, :target => :wkday).should_not be_valid
      EventSpecification.new(:repeat => :monthly, :on_the => 2).should_not be_valid
      EventSpecification.new(:repeat => :monthly, :on_the => :first, :target => :we).should_not be_valid
      EventSpecification.new(:repeat => :monthly, :on_the => :first, :on => [2]).should_not be_valid
    end
    
    it "generates an RRULE" do
      EventSpecification.new(:repeat => :monthly).to_rrule.should == "FREQ=MONTHLY;INTERVAL=1"
      EventSpecification.new(:repeat => :monthly, :frequency => 2).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2"
      EventSpecification.new(:repeat => :monthly, :frequency => 2, :on => [1, 15, 20]).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2;BYMONTHDAY=1,15,20"
      EventSpecification.new(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => :wkday).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2;BYSETPOS=3;BYDAY=MO,TU,WE,TH,FR"
      EventSpecification.new(:repeat => :monthly, :frequency => 2, :on_the => :third, :target => [:mo, :we]).to_rrule.should == "FREQ=MONTHLY;INTERVAL=2;BYSETPOS=3;BYDAY=MO,WE"
    end
  end
  
  describe "events recurring yearly" do
    it "passes validations" do
      EventSpecification.new(:repeat => :yearly, :on => [1,7]).should be_valid
      EventSpecification.new(:repeat => :yearly, :frequency => 2, :on => [1,7]).should be_valid
      EventSpecification.new(:repeat => :yearly, :on => [1,7], :on_the => :first, :target => :wkend).should be_valid
    end
    
    it "does not support invalid recurrence rules" do
      EventSpecification.new(:repeat => :yearly).should_not be_valid
      EventSpecification.new(:repeat => :yearly, :frequency => 3).should_not be_valid
      EventSpecification.new(:repeat => :yearly, :frequency => 'foo').should_not be_valid
      EventSpecification.new(:repeat => :yearly, :on => 2).should_not be_valid
      EventSpecification.new(:repeat => :yearly, :on => [2], :on_the => 'first').should_not be_valid
      EventSpecification.new(:repeat => :yearly, :on => [2], :on_the => :first, :target => 2).should_not be_valid
    end
    
    it "generates an RRULE" do
      EventSpecification.new(:repeat => :yearly, :on => [1,7]).to_rrule.should == "FREQ=YEARLY;INTERVAL=1;BYMONTH=1,7"
      EventSpecification.new(:repeat => :yearly, :frequency => 2, :on => [1,7]).to_rrule.should == "FREQ=YEARLY;INTERVAL=2;BYMONTH=1,7"
      EventSpecification.new(:repeat => :yearly, :on => [1,7], :on_the => :first, :target => :wkend).to_rrule.should == "FREQ=YEARLY;INTERVAL=1;BYMONTH=1,7;BYSETPOS=1;BYDAY=SU,SA"
    end
  end
end
