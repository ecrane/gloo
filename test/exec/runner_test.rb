require 'test_helper'

class RunnerTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
  end

  def test_running_verb
    s = 'show 3 + 4'
    v = @engine.parser.parse_immediate s
    assert v
    Gloo::Exec::Runner.go v
    assert_equal 7, @engine.heap.it.value
  end

  def test_running_object_at_path
    s = 'create s as script : "show 3 + 4"'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count

    Gloo::Exec::Runner.run( 's' )
    assert_equal 7, @engine.heap.it.value
  end

end
