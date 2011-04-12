# Jet Lag

Pulling on the timezone thread to see what unravels.

## Synopsis

This is a set of specs that explores the various combinations of ActiveRecord
and related time zone settings and their effect on timestamp values as written
and retrieved from a non-timezone-aware database.

The underlying motivation is to figure out the edge cases that exist when a
database is not running in UTC, and find where the ActiveRecord code fails to
handle this correctly.

## Requirements

* sqlite3
* ruby 1.8.7
* bundler
* rake

## Instructions

    bundle
    rake

