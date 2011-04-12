require "bundler"
Bundler.require :default

Spec::Runner.configure do |config|

  config.before :all do
    @dbfile = "/tmp/jetlag_test.db"
    FileUtils.rm @dbfile if File.exist?(@dbfile)
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => @dbfile
    )

    ActiveRecord::Migration.class_eval do
      create_table :items do |t|
        t.timestamp :ts, :null => false
      end
    end

    ActiveRecord::Base.remove_connection
  end

  config.after :all do
    ActiveRecord::Base.remove_connection
    FileUtils.rm @dbfile
  end

end

