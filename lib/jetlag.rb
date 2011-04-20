require "active_record"

module Jetlag

  class << self
    attr_accessor :enabled
    @enabled = false
  end

  module TimezoneAwareColumnQuoting
    # calling #getutc or #getlocal on a TimeWithZone will return the
    # underlying Time. This is desirable because Time#to_s(:db) does
    # *not* convert to UTC first, unlike TimeWithZone.
    # The same methods on a Time only change the timezone.
    #
    # This method is backported from Rails 3.
    def quoted_date(value)
      if ::Jetlag.enabled?
        if value.acts_like?(:time)
          zone_conversion_method = ActiveRecord::Base.default_timezone == :utc ? :getutc : :getlocal
          value.respond_to?(zone_conversion_method) ? value.send(zone_conversion_method) : value
        else
          value
        end.to_s(:db)
      else
        value.to_s(:db)
      end
    end
  end

  def self.enable
    unless ::ActiveRecord::ConnectionAdapters::AbstractAdapter.ancestors.include?(TimezoneAwareColumnQuoting)
      ::ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
        include TimezoneAwareColumnQuoting
      end
      ::ActiveRecord::Base.default_timezone = :local
    end

    @enabled = true
  end

  def self.disable
    @enabled = false
  end

  def self.enabled?
    @enabled
  end

end
