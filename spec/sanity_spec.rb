require "spec_helper"

describe "basic sanity checks" do

  before :all do
    Time.zone = nil
    connect_and_define_model
  end

  it "can load the columns from the test database" do
    @items.should have(2).columns
  end

  it "has the timezone set to US/Mountain" do
    ENV["TZ"].should == "US/Mountain"
  end

  it "has a sane representation for Time" do
    Time.parse("2011-04-12 11:30:00 -0600").inspect.should == "2011-04-12 11:30:00 -0600"
  end

  it "has a sane resentation for TimeWithZone" do
    Time.zone_default = Time.__send__(:get_zone, "Mountain Time (US & Canada)")
    Time.parse("2011-04-12 11:30:00 -0600").in_time_zone.inspect.should ==
      "Tue, 12 Apr 2011 11:30:00 MDT -06:00"
  end

end

