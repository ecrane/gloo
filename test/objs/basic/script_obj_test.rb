require 'test_helper'

class ScriptObjTest < BaseEngineTest

  def test_the_typename
    assert_equal 'script', Gloo::Objs::Script.typename
  end

  def test_the_short_typename
    assert_equal 'cmd', Gloo::Objs::Script.short_typename
  end

  def test_find_type
    @dic = @engine.dictionary

    assert @dic.find_obj( 'script' )
    assert @dic.find_obj( 'script' )
    assert @dic.find_obj( 'cmd' )
    assert @dic.find_obj( 'CMD' )
  end

  def test_setting_the_value
    o = Gloo::Objs::Script.new @engine
    o.set_value( 'show 2 + 3' )
    assert_equal 'show 2 + 3', o.value
  end

  def test_has_multiline_value
    o = Gloo::Objs::Script.new @engine
    assert o.multiline_value?
  end

  def test_messages
    msgs = Gloo::Objs::Script.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_running_a_script_obj
    @engine.log.quiet = true
    i = @engine.parser.parse_immediate 'create s as script : "show 3 + 4"'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'tell s to run'
    i.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_script_line_count_for_string
    o = Gloo::Objs::Script.new @engine
    assert_equal 0, o.line_count
    o.set_value ''
    assert_equal 0, o.line_count
    o.set_value 'help'
    assert_equal 'help', o.value
    assert_equal 4, o.value.strip.length
    assert o.value.is_a? String
    assert_equal 1, o.line_count
  end

  def test_script_line_count_for_array
    o = Gloo::Objs::Script.new @engine
    o.set_value 'help'
    o.add_line 'help verbs'
    assert_equal 2, o.line_count
  end

  def test_adding_line
    o = Gloo::Objs::Script.new @engine
    o.set_value 'help'
    assert o.value.is_a? String
    o.add_line 'help verbs'
    assert o.value.is_a? Array
  end

  def test_setting_array_value
    o = Gloo::Objs::Script.new @engine
    o.set_array_value [ 'help', 'help verbs' ]
    assert o.value.is_a? Array
    assert_equal 2, o.line_count
  end

  def test_running_a_multiline_script
    o = Gloo::Objs::Script.new @engine
    @engine.log.quiet = true
    o.set_value 'show 2 + 3'
    o.add_line 'show 1 + 2'
    o.msg_run
    assert_equal 3, @engine.heap.it.value
  end

end
