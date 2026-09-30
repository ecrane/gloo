require 'test_helper'

class DispatchTest < BaseEngineTest

  def test_message_dispatch
    s = Gloo::Objs::String.new @engine
    s.value = 'abc'
    assert s
    assert_equal 'abc', s.value

    Gloo::Exec::Dispatch.message( @engine, 'up', s )
    assert_equal 'ABC', s.value
  end

  def test_action_dispatch
    s = Gloo::Objs::String.new @engine
    s.value = 'abc'
    assert s
    assert_equal 'abc', s.value

    a = Gloo::Exec::Action.new 'up', s
    Gloo::Exec::Dispatch.action( @engine, a )
    assert_equal 'ABC', s.value
  end

  def test_send_message_by_path
    @engine.parser.run 'create s as string : hello'
    Gloo::Exec::Dispatch.send_message( @engine, 'up', 's' )
    assert_equal 'HELLO', @engine.heap.root.find_child( 's' ).value
  end

  def test_send_message_bad_path
    refute @engine.error?
    Gloo::Exec::Dispatch.send_message( @engine, 'up', 'no.such.obj' )
    assert @engine.error?
  end

  def test_unknown_message_is_one_error_and_no_warning
    @engine.parser.run 'create s as string : hi'
    warnings = capture_warnings { @engine.parser.run 'tell s to nosuchmsg' }
    assert_empty warnings
    assert_equal 1, @engine.heap.error.error_count
  end

  def test_message_to_a_missing_object_sets_it_false
    @engine.heap.it.set_to 'stale'
    @engine.parser.run 'tell no.such.obj to get_parent'
    assert @engine.error?
    assert_includes @engine.heap.error.value, "Object 'no.such.obj' was not found."
    assert_equal false, @engine.heap.it.value
  end

  def test_check_on_a_missing_object_sets_it_false
    @engine.heap.it.set_to 'stale'
    @engine.parser.run 'check no.such.obj for blank?'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  def test_message_the_object_does_not_take_sets_it_false
    @engine.parser.run "create s as string : 'hi'"
    @engine.heap.it.set_to 'stale'
    @engine.parser.run 'tell s to no_such_msg'
    assert @engine.error?
    assert_includes @engine.heap.error.value, 'cannot receive message no_such_msg'
    assert_equal false, @engine.heap.it.value
  end

  def test_message_to_it_still_leaves_it_unchanged
    @engine.parser.run "eval 'abc'"
    @engine.parser.run 'tell it to trim'
    assert @engine.error?
    assert_equal 'abc', @engine.heap.it.value
  end

end
