require 'test_helper'

class ActionTest < BaseEngineTest

  def test_creating_an_action
    s = Gloo::Objs::Script.new @engine
    o = Gloo::Exec::Action.new 'run', s

    assert o
    assert_equal 'run', o.msg
    assert_equal s, o.to
    refute o.params
  end

  def test_valid_action
    s = Gloo::Objs::Script.new @engine
    o = Gloo::Exec::Action.new 'run', s
    assert o.valid?

    o.msg = 'zsfasdfa23r2awf'
    refute o.valid?
  end

  def test_dispatch
    s = Gloo::Objs::String.new @engine
    s.name = 's'
    s.set_value 'hello'
    @engine.heap.root.add_child s

    o = Gloo::Exec::Action.new 'up', s
    o.dispatch
    assert_equal 'HELLO', s.value
  end

  def test_display_value
    s = Gloo::Objs::Script.new @engine
    s.name = 'myscript'
    @engine.heap.root.add_child s

    o = Gloo::Exec::Action.new 'run', s
    assert_equal 'run -> myscript', o.display_value
  end

end
