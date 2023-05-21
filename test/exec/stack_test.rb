require 'test_helper'

class StackTest < BaseEngineTest

  def test_debug_file
    o = Gloo::Exec::Stack.new( @engine, 'test' )
    assert o
    assert o.out_file.start_with? @engine.settings.debug_path
    assert o.out_file.end_with? 'test'
  end

  def test_pushing_poping
    o = Gloo::Exec::Stack.new( @engine, 'test' )
    assert o
    assert_equal 0, o.size

    o.push Gloo::Verbs::Run.new( @engine, nil )
    assert_equal 1, o.size
    o.pop
    assert_equal 0, o.size
  end

  def test_getting_out_data
    o = Gloo::Exec::Stack.new @engine, 'test'
    assert_equal '', o.out_data

    o.push Gloo::Verbs::Run.new( @engine, nil )
    assert_equal 'run', o.out_data
  end

end
