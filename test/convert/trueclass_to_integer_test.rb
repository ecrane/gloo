require 'test_helper'

class TrueClassToIntegerTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::TrueClassToInteger.new
    assert o
    assert_equal 1, o.convert( true )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create i as int'
    v.run
    o = @engine.heap.root.children.first

    v = @engine.parser.parse_immediate 'put true into i'
    v.run

    assert_equal 1, o.value
  end

end
