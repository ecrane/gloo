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

end
