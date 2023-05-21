require 'test_helper'

class TimeTest < BaseEngineTest

  def test_the_typename
    assert_equal 'time', GlooLang::Objs::Time.typename
  end

  def test_the_short_typename
    assert_equal 'time', GlooLang::Objs::Time.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'Time' )
  end

  def test_messages
    msgs = GlooLang::Objs::Time.messages
    assert msgs
    assert msgs.include?( 'now' )
  end

  def test_adds_children_on_create
    o = GlooLang::Objs::Time.new @engine
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
end
