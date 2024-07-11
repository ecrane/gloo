require 'test_helper'

class StringToDateTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::StringToDate.new
    assert o
    dt = DateTime.now
    assert_equal dt.strftime( '%Y.%m.%d' ), o.convert( 'now' ).strftime( '%Y.%m.%d' )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create d as date'
    v.run
    dt = @engine.heap.root.children.first

    v = @engine.parser.parse_immediate "put 'now' into d"
    v.run
    assert dt.value
    assert_equal dt.value, DateTime.now.strftime( '%Y.%m.%d' )
  end

end
