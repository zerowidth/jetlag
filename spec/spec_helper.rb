require "bundler"
Bundler.require :default, :development

require "rspec"
require "time" # for parse

# Jetlag.extend_ar

Rspec.configure do |config|

  config.before :all do
    ENV["TZ"] = "US/Mountain"

    @dbfile = "/tmp/jetlag_test.db"
    FileUtils.rm @dbfile if File.exist?(@dbfile)
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => @dbfile
    )

    ActiveRecord::Migration.class_eval do
      suppress_messages do
        create_table :items do |t|
          t.timestamp :ts, :null => false
        end
      end
    end

    ActiveRecord::Base.remove_connection
  end

  config.after :all do
    ActiveRecord::Base.remove_connection
    FileUtils.rm @dbfile
  end

  def connect_and_define_model
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => @dbfile
    )
    # the model is defined dynamically on request since the
    # AR::Base.time_zone_aware_attributes setting determines how
    # attribute writers are defined.
    @items = Class.new(ActiveRecord::Base) { set_table_name "items"}
  end

end

