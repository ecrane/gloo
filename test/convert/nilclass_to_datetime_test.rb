require 'test_helper'

class NilClassToDateTimeTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::NilClassToDateTime.new
    assert o
    assert_nil o.convert( nil )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create dt as datetime'
    v.run
    o = @engine.heap.root.children.first

    assert_nil o.value
  end

end
