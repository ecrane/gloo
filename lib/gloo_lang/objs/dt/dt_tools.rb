# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A Date and Time object.
#

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
  
end