require 'test_helper'

class DtToolsTest < BaseEngineTest

  def test_add
    t = Time.now
    t = DtTools.add( t, "1 day" )
    assert t > Time.now

    t = Time.now
    t = DtTools.add( t, "1 week" )
    assert t > Time.now

    t = Time.now
    t = DtTools.add( t, "1 month" )
    assert t > Time.now

    t = Time.now
    t = DtTools.add( t, "1 year" )
    assert t > Time.now
  end

  def test_add_time
    t = Time.now
    t = DtTools.add( t, "1 hour" )
    assert t > Time.now

    t = Time.now
    t = DtTools.add( t, "1 minute" )
    assert t > Time.now

    t = Time.now
    t = DtTools.add( t, "1 second" )
    assert t > Time.now
  end
    
  def test_subtract
    t = Time.now
    t = DtTools.sub( t, "1 day" )
    assert t < Time.now

    t = Time.now
    t = DtTools.sub( t, "1 week" )
    assert t < Time.now

    t = Time.now
    t = DtTools.sub( t, "1 month" )
    assert t < Time.now

    t = Time.now
    t = DtTools.sub( t, "1 year" )
    assert t < Time.now
  end

  def test_subtract_time
    t = Time.now
    t = DtTools.sub( t, "1 hour" )
    assert t < Time.now

    t = Time.now
    t = DtTools.sub( t, "1 minute" )
    assert t < Time.now

    t = Time.now
    t = DtTools.sub( t, "1 second" )
    assert t < Time.now
  end

  def test_is_today
    assert DtTools.is_today?( Time.now )

    refute DtTools.is_today?( "" )
    refute DtTools.is_today?( Time.now + 1.day )

    t = DateTime.now.strftime( '%Y.%m.%d %I:%M:%S %P' )
    assert DtTools.is_today?( t )
  end

  def test_is_this_week
    assert DtTools.is_this_week?( Time.now )
    refute DtTools.is_this_week?( "" )

    t = DateTime.now.strftime( '%Y.%m.%d %I:%M:%S %P' )
    assert DtTools.is_this_week?( t )
  end

  def test_is_tomorrow
    t = Chronic.parse '1 day from now'
    assert DtTools.is_tomorrow?( t )

    refute DtTools.is_tomorrow?( "" )
    refute DtTools.is_tomorrow?( Time.now )

    t = t.strftime( '%Y.%m.%d %I:%M:%S %P' )
    assert DtTools.is_tomorrow?( t )
  end

  def test_is_yesterday
    t = Chronic.parse '1 day ago'
    assert DtTools.is_yesterday?( t )

    refute DtTools.is_yesterday?( "" )
    refute DtTools.is_yesterday?( Time.now )

    t = t.strftime( '%Y.%m.%d %I:%M:%S %P' )
    assert DtTools.is_yesterday?( t )
  end

  def test_beginning_of_week
    b = DtTools.beginning_of_week
    assert b
    assert b < Time.now
  end

  def test_in_next_10_days
    dt = Chronic.parse( "3 days from now" )
    assert DtTools.in_next_ten_days?( dt )

    dt = Chronic.parse( "9 days from now" )
    assert DtTools.in_next_ten_days?( dt )

    dt = Chronic.parse( "11 days from now" )
    refute DtTools.in_next_ten_days?( dt )

    dt = Chronic.parse( "23 days from now" )
    refute DtTools.in_next_ten_days?( dt )

    dt = Chronic.parse( "yesterday" )
    refute DtTools.in_next_ten_days?( dt )
  end

  def test_in_past
    dt = Chronic.parse( "3 days from now" )
    refute DtTools.is_past?( dt )

    refute DtTools.is_past?( Time.now )

    dt = Chronic.parse( "13 days ago" )
    assert DtTools.is_past?( dt )

    dt = Chronic.parse( "yesterday" )
    assert DtTools.is_past?( dt )
  end

  def test_in_future
    dt = Chronic.parse( "3 days from now" )
    assert DtTools.is_future?( dt )

    refute DtTools.is_future?( Time.now )

    dt = Chronic.parse( "13 days ago" )
    refute DtTools.is_future?( dt )

    dt = Chronic.parse( "tomorrow" )
    assert DtTools.is_future?( dt )
  end

end
