require 'test_helper'

class DatetimeTest < BaseEngineTest

  def test_the_typename
    assert_equal 'datetime', Gloo::Objs::Datetime.typename
  end

  def test_the_short_typename
    assert_equal 'dt', Gloo::Objs::Datetime.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Datetime.doc_data
    assert_equal Gloo::Objs::Datetime.typename, data[:name]
    assert_equal Gloo::Objs::Datetime.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'datetime' )
    assert @dic.find_obj( 'DT' )
  end

  def test_messages
    msgs = Gloo::Objs::Datetime.messages
    assert msgs
    assert msgs.include?( 'now' )
    assert msgs.include?( 'format' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Datetime.new @engine
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

  def test_format_msg
    o = Gloo::Objs::Datetime.new @engine
    o.set_value( DateTime.new( 2025, 10, 15, 14, 30, 0 ) )

    o.msg_format
    assert_equal '2025-10-15 14:30:00', @engine.heap.it.value
  end

  def test_format_msg_with_format_string
    i = @engine.parser.parse_immediate 'create dt as dt'
    i.run
    dt = @engine.heap.root.children.first
    dt.set_value( DateTime.new( 2025, 10, 15, 14, 30, 0 ) )

    i = @engine.parser.parse_immediate "tell dt to format ('%m/%d/%Y')"
    i.run
    assert_equal '10/15/2025', @engine.heap.it.value
  end

end
