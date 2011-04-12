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
  end

end
