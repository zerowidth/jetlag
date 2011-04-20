# Jetlag

Patches for ActiveRecord 2.3.x timezone-handling code to allow for non-UTC
databases.

Rails 3 mostly works, see discussion below.

## Synopsis

This rails plugin patches ActiveRecord to fix the time quoting when timezones
are involved, especially when using a non-UTC database.

This started as a set of specs to explore the various combinations of
ActiveRecord and related time zone settings and their effect on timestamp values
as written and retrieved from a non-timezone-aware database.

The underlying motivation was to figure out the edge cases that exist when a
database is not running in UTC, and find where the ActiveRecord code fails to
handle this correctly. Eventually it ended up becoming a patch to correct the
invalid behavior.

## Rails 3

Rails 3 timezone handling is correct, especially with the default settings. If
your database is not in UTC, make sure `ENV["TZ"]` for your rails app is set
appropriately, and set `ActiveRecord::Base.default_timezone = :local`. For more
details, see the rails3 branch -- there are specs there showing that the
behavior is correct, even when changing Time.zone "per request".

## Discussion

The rails convention is to keep all data in UTC. If, however, due to legacy
reasons, your database is *not* UTC, Rails is unable to write (and thus read)
dates with the correct timezone. This can lead to subtle bugs and, essentially,
corrupted data.

ActiveRecord does the incorrect thing in the following cases (copied from spec
output):

    with Time.zone_default set (i.e. config.time_zone=) and default_timezone = :local and time_zone_aware_attributes = true (default)
    - writes local Time objects to the database in UTC (invalid storage)
    - writes local UTC Time objects as UTC (invalid storage)
    - writes TimeWithZone objects using UTC (invalid storage)
    - reads the timestamp as local but with the UTC offset (invalid round-trip)

    with Time.zone_default set (i.e. config.time_zone=) and default_timezone = :local and time_zone_aware_attributes = false
    - writes bare UTC timestamps as UTC (invalid storage)
    - writes TimeWithZone objects as UTC (invalid storage)

    with Time.zone_default set (i.e. config.time_zone=) and AR::Base.default_timezone = :utc (default) and time_zone_aware_attributes = false
    - does not write bare timestamps as UTC (invalid storage)
    - reads the timestamp as UTC (invalid round trip)

    with Time.zone_default not set (i.e. config.time_zone is nil) with default_timezone as :local (default)
    - writes bare UTC timestamps as UTC (invalid storage)

    with Time.zone_default not set (i.e. config.time_zone is nil) with default_timezone as :utc
    - does not write local timestamps as UTC (invalid storage)

Jetlag patches AR's column quoting to handle timezones correctly.

## Installation

To use in your Rails 2.3.x application (as a plugin):

    script/plugin install https://github.com/aniero/jetlag.git

If your database is not in UTC, set `ENV["TZ"]` explicitly in your
`config/environment.rb` to match the database's timezone, and also add the
following line after `config.time_zone = 'UTC'`:

    config.active_record.default_timezone = :local

To run manually, e.g. non-rails use of ActiveRecord:

    require "jetlag"
    Jetlag.enable

To run the specs:

    bundle
    rake

