# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A Date and Time object.
#
require 'active_support/time'

class DtTools

  # ---------------------------------------------------------------------
  #    Type helpers
  # ---------------------------------------------------------------------

  # 
  # Is the given object a base Date Time object?
  # True for DateTime and Time
  # 
  def self.is_dt_type? obj
    return true if obj.is_a? ::DateTime
    return true if obj.is_a? ::Time
    return false
  end


  # ---------------------------------------------------------------------
  #    Date Math
  # ---------------------------------------------------------------------

  # 
  # Given a date, add the modifier to it.
  # The modifier takes the form of "1 day" or "2 weeks".
  # 
  def self.add date, modifier="1 day"
    # Split out amount and unit
    amount, unit = modifier.split(' ')  

    # converts "1 day" to 1.day
    duration = amount.to_i.send( unit )
    return date + duration
  end

  # 
  # Given a date, subtract the modifier from it.
  # The modifier takes the form of "1 day" or "2 weeks".
  # 
  def self.sub dt, modifier="1 day"
    # Split out amount and unit
    amount, unit = modifier.split(' ')  

    # converts "1 day" to 1.day
    duration = amount.to_i.send( unit )  
    return dt - duration
  end


  # ---------------------------------------------------------------------
  #    Language helpers
  # ---------------------------------------------------------------------

  # 
  # Get the beginning of the week.
  # 
  def self.beginning_of_week
    return Time.now.beginning_of_week( start_day = :sunday )
  end

  # 
  # Is the date in the next 10 days?
  # 
  def self.in_next_ten_days?( dt )
    return false if DtTools.is_past?( dt )
    dt < 10.days.from_now.end_of_day
  end

  # 
  # Is the date in the past?
  # 
  def self.is_past?( dt )
    dt < Time.now.beginning_of_day
  end

  #
  # Is the date in the future?
  #
  def self.is_future?( dt )
    dt > Time.now.end_of_day
  end

  # 
  # Is the given date today?
  # 
  def self.is_today?( dt )
    return false if dt.blank?
    dt = Chronic.parse( dt ) if dt.is_a? String
    return false if dt <= ::Time.now.beginning_of_day
    return false if dt >= ::Time.now.end_of_day
    return true
  end

  # 
  # Is the given date tomorrow?
  # 
  def self.is_tomorrow?( dt )
    return false if dt.blank?
    dt = Chronic.parse( dt ) if dt.is_a? String
    return false if dt <= ( ::Time.now.beginning_of_day + 1.day )
    return false if dt >= ( ::Time.now.end_of_day + 1.day )
    return true
  end

  # 
  # Is the given date yesterday?
  # 
  def self.is_yesterday?( dt )
    return false if dt.blank?
    dt = Chronic.parse( dt ) if dt.is_a? String
    return false if dt <= ( ::Time.now.beginning_of_day - 1.day )
    return false if dt >= ( ::Time.now.end_of_day - 1.day )
    return true
  end

  # 
  # Is the given date this week?
  # 
  def self.is_this_week?( dt )
    return false if dt.blank?
    dt = Chronic.parse( dt ) if dt.is_a?( String )
    return false if dt <= ::Time.now.beginning_of_week( start_day = :sunday )
    return false if dt >= ::Time.now.end_of_week( start_day = :sunday )
    return true
  end
  

  # ---------------------------------------------------------------------
  #    Begin/end Helpers
  # ---------------------------------------------------------------------

  def self.get_utc_offset t
    utc_offset = ActiveSupport::TimeZone[ t.zone ].utc_offset
    return utc_offset
  end
  
  # 
  # Returns the beginning of the month for the given time.
  # 
  def self.beginning_of_month t
    utc_offset = get_utc_offset t
    Time.new(t.year, t.month, 1, 0, 0, 0, utc_offset)
  end

  #
  # Returns the end of the month for the given time.
  #
  def self.end_of_month t
    utc_offset = get_utc_offset t
    Time.new(t.year, t.month, t.end_of_month.day, 23, 59, 59, utc_offset)
  end

  # ---------------------------------------------------------------------
  #    Comparison
  # ---------------------------------------------------------------------

  # Kind pairings that can never be compared, even though both sides
  # look like date/time values (eg. a time can't be compared to a date).
  INCOMPATIBLE_DT_KINDS = [
    [ :date, :time ], [ :time, :date ],
    [ :time, :datetime ], [ :datetime, :time ]
  ].freeze

  #
  # What kind of date/time value does this string look like?
  # Returns :date, :time, :datetime, or nil if it doesn't match
  # the exact format that gloo date/time/datetime objects use.
  #
  def self.dt_kind( value )
    return nil unless value.is_a? String
    return :datetime if value =~ /\A\d{4}\.\d{2}\.\d{2}\s\d{2}:\d{2}:\d{2}\s(am|pm)\z/i
    return :date if value =~ /\A\d{4}\.\d{2}\.\d{2}\z/
    return :time if value =~ /\A\d{2}:\d{2}:\d{2}\s(am|pm)\z/i

    return nil
  end

  #
  # Strictly parse a string using the exact format for the given kind.
  #
  def self.strict_dt_parse( kind, str )
    format = { date: Gloo::Objs::Date::DEFAULT_FORMAT,
               time: Gloo::Objs::Time::DEFAULT_FORMAT,
               datetime: Gloo::Objs::Datetime::DEFAULT_FORMAT }[ kind ]
    return ::DateTime.strptime( str, format )
  rescue StandardError
    return nil
  end

  #
  # Reduce a parsed value down to the granularity of the given kind,
  # so a strictly-parsed value and a loosely-parsed value can be compared.
  #
  def self.normalize_dt( kind, dt )
    return dt.to_date if kind == :date
    return [ dt.hour, dt.min, dt.sec ] if kind == :time

    return dt
  end

  #
  # Loosely parse an arbitrary string (eg. "3 days from now") and reduce
  # it to the granularity of the given kind for comparison.
  #
  # Bare numbers (eg. "11", "2026") are rejected even though Chronic can
  # parse them - it treats them as an hour or day-of-month relative to
  # today, which is misleading rather than a genuine date/time value.
  #
  def self.loose_dt_parse( kind, str )
    return nil if str =~ /\A\s*\d+\s*\z/

    dt = Chronic.parse( str )
    return nil if dt.nil?

    return normalize_dt( kind, dt.to_datetime )
  rescue StandardError
    return nil
  end

  #
  # Compare two raw values with date/time/datetime semantics.
  # Returns :not_dt if neither value looks like a date, time, or datetime,
  # so the caller can fall back to its normal comparison logic.
  # Otherwise returns -1, 0, or 1 (as with <=>), or nil if the two
  # values can't be meaningfully compared.
  #
  def self.compare_dt( left, right )
    l_kind = dt_kind( left )
    r_kind = dt_kind( right )
    return :not_dt if l_kind.nil? && r_kind.nil?

    if l_kind && r_kind
      return nil if INCOMPATIBLE_DT_KINDS.include?( [ l_kind, r_kind ] )

      l = strict_dt_parse( l_kind, left )
      r = strict_dt_parse( r_kind, right )
      return nil if l.nil? || r.nil?

      return l <=> r
    end

    # Only one side looks like a date/time/datetime value. Try to parse
    # the other side as that same kind (eg. a date compared to a string).
    kind = l_kind || r_kind
    known, other = l_kind ? [ left, right ] : [ right, left ]
    return nil unless other.is_a? String

    k = strict_dt_parse( kind, known )
    return nil if k.nil?

    o = loose_dt_parse( kind, other )
    return nil if o.nil?

    result = normalize_dt( kind, k ) <=> o
    return l_kind ? result : -result
  end

end