require 'test_helper'

class TimeTest < BaseEngineTest

  def test_the_typename
    assert_equal 'time', Gloo::Objs::Time.typename
  end

  def test_the_short_typename
    assert_equal 'time', Gloo::Objs::Time.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'Time' )
  end

  def test_messages
    msgs = Gloo::Objs::Time.messages
    assert msgs
    assert msgs.include?( 'now' )
    assert msgs.include?( 'format' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Time.new @engine
    refute o.add_children_on_create?
  end

  def test_now
    i = @engine.parser.parse_immediate 'create t as time'
    i.run
    t = @engine.heap.root.children.first
    assert t
    refute t.value

    i = @engine.parser.parse_immediate 'tell t to now'
    i.run
    refute_equal '', t.value
  end

  def test_setting_from_string
    i = @engine.parser.parse_immediate 'create t as time'
    i.run
    t = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate "put 'tomorrow' into t"
    i.run

    refute_equal 'tomorrow', t.value
  end

  def test_put_dt_into_t
    i = @engine.parser.parse_immediate 'create t as time'
    i.run
    t = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate 'create dt as datetime'
    i.run
    dt = @engine.heap.root.children.last

    i = @engine.parser.parse_immediate "tell dt to now"
    i.run
    assert dt.value
    refute t.value
    i = @engine.parser.parse_immediate "put dt into t"
    i.run
    assert t.value

    assert dt.value.end_with?( t.value )
  end

  def test_format_msg
    o = Gloo::Objs::Time.new @engine
    o.set_value( Time.new( 2025, 10, 15, 14, 30, 0 ) )

    o.msg_format
    assert_equal '14:30:00', @engine.heap.it.value
  end

  def test_format_msg_with_format_string
    i = @engine.parser.parse_immediate 'create t as time'
    i.run
    t = @engine.heap.root.children.first
    t.set_value( Time.new( 2025, 10, 15, 14, 30, 0 ) )

    i = @engine.parser.parse_immediate "tell t to format ('%I:%M %p')"
    i.run
    assert_equal '02:30 PM', @engine.heap.it.value
  end
end
