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

end
