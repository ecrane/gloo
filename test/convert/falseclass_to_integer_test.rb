require 'test_helper'

class FalseClassToIntegerTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::FalseClassToInteger.new
    assert o
    assert_equal 0, o.convert( false )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create i as int'
    v.run
    o = @engine.heap.root.children.first

    v = @engine.parser.parse_immediate 'put false into i'
    v.run

    assert_equal 0, o.value
  end

end
