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

end