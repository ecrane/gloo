require 'test_helper'

class NilClassToIntegerTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::NilClassToInteger.new
    assert o
    assert_equal 0, o.convert( nil )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create x as integer'
    v.run
    o = @engine.heap.root.children.first

    assert_equal 0, o.value
  end

end
