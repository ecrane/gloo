require 'test_helper'

class RunnerTest < BaseEngineTest

  def test_running_verb
    s = 'show 3 + 4'
    v = @engine.parser.parse_immediate s
    assert v
    Gloo::Exec::Runner.go @engine, v
    assert_equal 7, @engine.heap.it.value
  end

  def test_running_object_at_path
    s = 'create s as script : "show 3 + 4"'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count

    Gloo::Exec::Runner.run( @engine, 's' )
    assert_equal 7, @engine.heap.it.value
  end

  def test_running_bad_path
    refute @engine.error?
    Gloo::Exec::Runner.run( @engine, 'no.such.script' )
    assert @engine.error?
  end

  def test_verb_stack_pops_even_when_verb_raises
    starting_size = @engine.exec_env.verbs.size
    @engine.parser.run 'throw "boom"'
    assert_equal starting_size, @engine.exec_env.verbs.size
  end

  def test_exception_in_a_script_line_does_not_abort_later_lines
    o = Gloo::Objs::Script.new @engine
    o.set_array_value( [ 'throw "boom"', 'show 3 + 4' ] )

    s = Gloo::Exec::Script.new( @engine, o )
    s.run
    assert_equal 7, @engine.heap.it.value
  end

end
