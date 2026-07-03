require 'test_helper'

class StringToTimeTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::StringToTime.new
    assert o
    dt = DateTime.now
    assert_equal dt.strftime( '%H:%M' ), o.convert( 'now' ).strftime( '%H:%M' )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create t as time'
    v.run
    t = @engine.heap.root.children.first

    v = @engine.parser.parse_immediate "put 'now' into t"
    v.run
    assert t.value
  end

end
