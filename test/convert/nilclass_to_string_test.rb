require 'test_helper'

class NilClassToStringTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::NilClassToString.new
    assert o
    assert_equal '', o.convert( nil )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create s as string'
    v.run
    o = @engine.heap.root.children.first

    assert_equal '', o.value
  end

end
