require "active_record"

module Jetlag

  module TimezoneAwareColumnQuoting
    def quoted_date(value)
      if ActiveRecord::Base.database_timezone == :utc
        super value.utc
      elsif ActiveRecord::Base.database_timezone == :local
        super value.localtime
      else
        super
      end
    end
  end

  def self.extend_ar
    ::ActiveRecord::Base.module_eval do
      cattr_accessor :database_timezone
      self.database_timezone = :utc
    end

    ::ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
      include TimezoneAwareColumnQuoting
    end

    # couldn't do it with modules, so monkeypatch it direct!
    ::ActiveRecord::ConnectionAdapters::Column.module_eval do

      # when parsing a time from the database, handle mismatches between
      # the database' timestamp and the AR default timestamp
      def self.new_time_with_db_fix(year, mon, mday, hour, min, sec, microsec)
        return nil if year.nil? || year == 0

        if ActiveRecord::Base.database_timezone == :utc && ActiveRecord::Base.default_timezone == :local
          time = Time.time_with_datetime_fallback(:utc, year, mon, mday, hour, min, sec, microsec) rescue nil
          return time.localtime if time

        elsif ActiveRecord::Base.database_timezone == :local && ActiveRecord::Base.default_timezone == :utc
          time = Time.time_with_datetime_fallback(:local, year, mon, mday, hour, min, sec, microsec) rescue nil
          return time.gmtime if time

        else
          new_time_without_db_fix(year, mon, mday, hour, min, sec, microsec)
        end
      end

      class << self
        alias_method_chain :new_time, :db_fix
      end
    end

  end

end
