require "spec_helper"

describe "AR with Time.zone_default set" do

  # In rails 3, Time.zone_default is *always* set, with a default of UTC.

  before :all do
    Time.zone_default = Time.__send__(:get_zone, "Mountain Time (US & Canada)")
    ActiveRecord::Base.default_timezone = :utc # default
    ActiveRecord::Base.time_zone_aware_attributes = true # default

    # disable jetlag altogether
    # ActiveRecord::Base.database_timezone = nil
  end

  before :each do
    @time = Time.parse("2011-04-12 11:30:00 -0600")
  end

  context "and default_timezone = :local" do
    before :all do
      ActiveRecord::Base.default_timezone = :local
    end

    context "and time_zone_aware_attributes = true (default)" do
      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = true
        connect_and_define_model
      end

      it "writes local Time objects to the database as local time (ok)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00.000000"
      end

      it "writes local UTC Time objects as UTC (ok)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00.000000"
      end

      it "writes TimeWithZone objects using the local timezone" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00.000000"
      end

      it "reads the timestamp in the local timezone (ok)" do
        item = @items.create :ts => @time
        ts = item.reload.ts
        ts.inspect.should == "Tue, 12 Apr 2011 11:30:00 MDT -06:00"
      end
    end

    context "and time_zone_aware_attributes = false" do
      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = false
        connect_and_define_model
      end

      it "writes local Time timestamps correctly (ok)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00.000000"
      end

      it "writes UTC Time in local timezone (ok)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00.000000"
      end

      it "writes TimeWithZone objects correctly (ok)" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00.000000"
      end

      it "reads the timestamp as local with the correct offset (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 -0600"
      end
    end

  end

  context "and AR::Base.default_timezone = :utc (default)" do
    before :all do
      ActiveRecord::Base.default_timezone = :utc
    end

    context "and time_zone_aware_attributes = true (default)" do
      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = true
        connect_and_define_model
      end

      it "writes bare Time objects to the database in UTC (ok)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00.000000"
      end

      it "writes bare UTC timestamps as UTC (ok)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00.000000"
      end

      it "writes TimeWithZone objects in UTC (ok)" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00.000000"
      end

      it "reads the timestamp as UTC but keeps it in the local timezone (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "Tue, 12 Apr 2011 11:30:00 MDT -06:00"
      end

    end

    context "and time_zone_aware_attributes = false" do
      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = false
        connect_and_define_model
      end

      it "writes bare timestamps in UTC (invalid serialization)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00.000000"
      end

      it "writes bare UTC timestamps as local time (invalid serialization)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00.000000"
      end

      it "writes TimeWithZone objects as UTC (invalid serialization)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00.000000"
      end

      it "reads the timestamp as UTC (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 17:30:00 UTC"
      end
    end

  end

end

