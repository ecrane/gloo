require 'test_helper'

class ScriptTest < BaseEngineTest

  def test_script_initialization
    o = Gloo::Objs::Script.new @engine
    o.set_value( 'show 2 + 3' )
    s = Gloo::Exec::Script.new( @engine, o )
    assert s
    assert_equal s.obj, o
  end

  def test_running_a_script
    o = Gloo::Objs::Script.new @engine
    o.set_value( 'show 2 + 3' )

    s = Gloo::Exec::Script.new( @engine, o )
    assert s
    s.run
    assert_equal 5, @engine.heap.it.value
  end

  def test_display_value
    @engine.parser.run 'create s as script : "show 3 + 4"'
    assert_equal 1, @engine.heap.root.child_count
    o = @engine.heap.root.children.first

    s = Gloo::Exec::Script.new( @engine, o )
    assert s
    assert_equal 's', s.display_value
    s.run
    assert_equal 7, @engine.heap.it.value
  end

end
