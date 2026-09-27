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

  def test_valid
    o = Gloo::Convert::StringToTime.new
    %w[13:45 noon].each { |v| assert o.valid?( v, o.convert( v ) ), v }
    assert o.valid?( '', nil )
    refute o.valid?( 'notatime', o.convert( 'notatime' ) )
    refute o.valid?( '25:99', o.convert( '25:99' ) )
  end

end
