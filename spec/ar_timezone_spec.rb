require "spec_helper"

context "with Time.zone_default set (i.e. config.time_zone=)" do

  before :all do
    # simulate the initialize_time_zone rails initializer
    Time.zone_default = Time.__send__(:get_zone, "Mountain Time (US & Canada)")
    ActiveRecord::Base.default_timezone = :utc
    ActiveRecord::Base.time_zone_aware_attributes = true
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

      it "writes bare Time objects to the database in UTC (invalid storage)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "writes bare UTC timestamps as UTC (invalid writer)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "writes TimeWithZone objects in UTC (invalid storage)" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "reads the timestamp as local but with the UTC offset (invalid round-trip)" do
        item = @items.create :ts => @time
        ts = item.reload.ts
        ts.inspect.should == "Tue, 12 Apr 2011 17:30:00 MDT -06:00"
      end
    end

    context "and time_zone_aware_attributes = false" do
      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = false
        connect_and_define_model
      end

      it "does not write bare timestamps as UTC (ok)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes bare UTC timestamps as UTC (invalid writer)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "writes TimeWithZone objects as UTC (invalid storage)" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
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
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "writes bare UTC timestamps as UTC (ok)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "writes TimeWithZone objects in UTC (ok)" do
        item = @items.create :ts => @time.in_time_zone
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "reads the timestamp as UTC but keeps it in the local timezone (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "Tue, 12 Apr 2011 11:30:00 MDT -06:00"
      end

    end

    context "and time_zone_aware_attributes = false (overridden)" do
      before :all do
        ActiveRecord::Base.time_zone_aware_attributes = false
        connect_and_define_model
      end

      it "does not write bare timestamps as UTC (invalid storage)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes bare UTC timestamps as UTC (ok)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "writes TimeWithZone objects as UTC (ok)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "reads the timestamp as UTC (invalid round trip)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 UTC"
      end
    end

  end

end

context "with Time.zone_default not set (i.e. config.time_zone is nil)" do
  before :all do
    Time.zone_default = nil
    ActiveRecord::Base.default_timezone = :local
    ActiveRecord::Base.time_zone_aware_attributes = false

    connect_and_define_model
  end

  before :each do
    @time = Time.parse("2011-04-12 11:30:00 -0600")
  end

  context "with default_timezone as :local (default)" do

    context "without timezone aware attributes (default)" do

      it "does not write local timestamps as UTC (ok)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes bare UTC timestamps as UTC (invalid writer)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "reads the timestamp as local with the correct offset (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 -0600"
      end

    end

    context "with timezone aware attributes" do

      it "does not write timestamps as UTC (ok)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes bare UTC timestamps as UTC (invalid writer)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "reads the timestamp as local with the correct offset (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 -0600"
      end
    end

  end

  context "with default_timezone as :utc" do
    before :all do
      ActiveRecord::Base.default_timezone = :utc
    end

    context "without timezone aware attributes (default)" do

      it "does not write local timestamps as UTC (invalid writer)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes bare UTC timestamps as UTC (ok)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "reads the timestamp as UTC with the correct offset (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 UTC"
      end

    end

    context "with timezone aware attributes" do

      it "does not write timestamps as UTC (invalid storage)" do
        item = @items.create :ts => @time
        item.reload.ts_before_type_cast.should == "2011-04-12 11:30:00"
      end

      it "writes bare UTC timestamps as UTC (ok)" do
        item = @items.create :ts => @time.utc
        item.reload.ts_before_type_cast.should == "2011-04-12 17:30:00"
      end

      it "reads the timestamp as UTC with the correct offset (ok)" do
        item = @items.create :ts => @time
        item.reload.ts.inspect.should == "2011-04-12 11:30:00 UTC"
      end
    end

  end

end
