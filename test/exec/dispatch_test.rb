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

end
