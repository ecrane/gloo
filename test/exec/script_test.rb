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

  def test_break_out
    o = Gloo::Objs::Script.new @engine
    o.set_value( [ 'show 1', 'show 2', 'show 3' ] )

    s = Gloo::Exec::Script.new( @engine, o )
    s.break_out
    s.run
    refute_equal 3, @engine.heap.it.value
  end

  def test_setting_the_script_with_put
    @engine.parser.run 'create s as script'
    @engine.parser.run 'put "eval 3 + 4" into s'
    @engine.parser.run 'run s'
    assert_equal 7, @engine.heap.it.value
  end

  def test_error_location_is_the_script_line
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.s as script'
    s = @engine.heap.root.find_child( 'c' ).find_child( 's' )
    s.add_line 'show 1'
    s.add_line 'show no.such.obj'
    @engine.parser.run 'run c.s'
    assert_equal 'c.s, line 2', @engine.heap.error.location
  end

end
