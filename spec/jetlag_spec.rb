require "spec_helper"

describe Jetlag do

  before :all do
    Jetlag.enable
  end

  before :each do
    @time = Time.parse("2011-04-12 11:30:00 -0600")
  end

  context "with config.time_zone" do

    before :all do
      Time.zone_default = Time.__send__(:get_zone, "Mountain Time (US & Canada)")
      ActiveRecord::Base.default_timezone = :local
      ActiveRecord::Base.time_zone_aware_attributes = true
    end

    context "with timezone aware attributes" do
      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = true
        connect_and_define_model
      end

      it "writes local Time to the database in local time" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes utc Time to the database in local time" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes TimeWithZone to the database in local time" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "reads a timestamp as a valid TimeWithZone" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "Tue, 12 Apr 2011 11:30:00 MDT -06:00"
      end

    end

    context "without timezone aware attributes" do

      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = false
        connect_and_define_model
      end

      it "writes local Time to the database in local time" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes utc Time to the database in local time" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes TimeWithZone to the database in local time" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "reads a timestamp as a valid Time" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 -0600"
      end

    end

  end # configured timezone

  context "without config.timezone" do

    before :all do
      Time.zone_default = nil
      ActiveRecord::Base.default_timezone = :local
      ActiveRecord::Base.time_zone_aware_attributes = false

      connect_and_define_model
    end


    context "with default_timezone as :local (default)" do
      it "writes UTC time as local" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "reads time as local" do
        item = @items.create :ts => @time.utc
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 -0600"
      end
    end

    context "with default_timezone as :utc" do
      before :all do
        ActiveRecord::Base.default_timezone = :utc
      end

      it "writes local Time as utc (wrong, but expected)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "reads time as UTC" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 17:30:00 UTC"
      end
    end

  end

end
