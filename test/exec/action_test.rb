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

end
