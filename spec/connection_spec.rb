require "spec_helper"

describe "an Items model" do

  before :each do
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => @dbfile
    )
  end

  after :each do
    ActiveRecord::Base.remove_connection
  end

  it "loads the columns from the test database" do
    i = Class.new(ActiveRecord::Base) { set_table_name "items" }
    i.should have(2).columns
  end
end

