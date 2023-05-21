require 'test_helper'

class DatetimeTest < BaseEngineTest

  def test_the_typename
    assert_equal 'datetime', GlooLang::Objs::Datetime.typename
  end

  def test_the_short_typename
    assert_equal 'dt', GlooLang::Objs::Datetime.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'datetime' )
    assert @dic.find_obj( 'DT' )
  end

  def test_messages
    msgs = GlooLang::Objs::Datetime.messages
    assert msgs
    assert msgs.include?( 'now' )
  end

  def test_adds_children_on_create
    o = GlooLang::Objs::Datetime.new @engine
    refute o.add_children_on_create?
  end

  def test_setting_from_string
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    i = @engine.parser.parse_immediate "put '3 weeks from now' into dt"
    i.run

    i = @engine.parser.parse_immediate 'tell dt to is_this_week'
    i.run
    refute @engine.heap.it.value
  end

  def test_now
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    t = @engine.heap.root.children.first
    assert t
    refute t.value

    i = @engine.parser.parse_immediate 'tell dt to now'
    i.run
    refute_equal '', t.value
  end

  def test_is_today_message
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to now'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to is_today'
    i.run
    assert @engine.heap.it.value

    i = @engine.parser.parse_immediate "put 'tomorrow' into dt"
    i.run

    i = @engine.parser.parse_immediate 'tell dt to is_today'
    i.run
    refute @engine.heap.it.value
  end

  def test_is_yesterday_message
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to now'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to is_yesterday'
    i.run
    refute @engine.heap.it.value

    i = @engine.parser.parse_immediate "put 'yesterday' into dt"
    i.run

    i = @engine.parser.parse_immediate 'tell dt to is_yesterday'
    i.run
    assert @engine.heap.it.value
  end

  def test_is_tomorrow_message
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to now'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to is_tomorrow'
    i.run
    refute @engine.heap.it.value

    i = @engine.parser.parse_immediate "put 'tomorrow' into dt"
    i.run

    i = @engine.parser.parse_immediate 'tell dt to is_tomorrow'
    i.run
    assert @engine.heap.it.value
  end

  def test_is_this_week_message
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to now'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to is_this_week'
    i.run
    assert @engine.heap.it.value

    i = @engine.parser.parse_immediate "put '2 weeks ago' into dt"
    i.run

    i = @engine.parser.parse_immediate 'tell dt to is_this_week'
    i.run
    refute @engine.heap.it.value
  end

  def test_convert
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    dt = @engine.heap.root.children.first
    assert dt
    refute dt.value

    i = @engine.parser.parse_immediate "put 'tomorrow' into dt"
    i.run
    refute_equal 'tomorrow', dt.value
    assert DtTools.is_tomorrow?( dt.value )
  end

  def test_is_past_message
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to now'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to is_past'
    i.run
    refute @engine.heap.it.value

    i = @engine.parser.parse_immediate "put 'yesterday' into dt"
    i.run

    i = @engine.parser.parse_immediate 'tell dt to is_past'
    i.run
    assert @engine.heap.it.value
  end

  def test_is_future_message
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to now'
    i.run
    i = @engine.parser.parse_immediate 'tell dt to is_future'
    i.run
    refute @engine.heap.it.value

    i = @engine.parser.parse_immediate "put 'tomorrow' into dt"
    i.run

    i = @engine.parser.parse_immediate 'tell dt to is_future'
    i.run
    assert @engine.heap.it.value
  end

end
