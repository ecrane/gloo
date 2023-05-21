require 'test_helper'

class StringToDateTimeTest < BaseEngineTest

  def test_conversion
    o = GlooLang::Convert::StringToDateTime.new
    assert o
    dt = DateTime.now
    assert_equal dt.strftime( '%Y.%m.%d' ), o.convert( 'now' ).strftime( '%Y.%m.%d' )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create dt as datetime'
    v.run
    dt = @engine.heap.root.children.first

    v = @engine.parser.parse_immediate "put 'now' into dt"
    v.run
    assert dt.value
    assert dt.value.start_with?( DateTime.now.strftime( '%Y.%m.%d' ) )
  end

end
