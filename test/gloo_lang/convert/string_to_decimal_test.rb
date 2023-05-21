require 'test_helper'

class StringToDecimalTest < BaseEngineTest

  def test_conversion
    o = GlooLang::Convert::StringToDecimal.new
    assert o
    assert_equal 3.1, o.convert( '3.1' )
    assert_equal 0.0, o.convert( '0.0' )
    assert_equal 987.65, o.convert( '987.65' )
  end

  def test_with_engine
    @engine.parser.run 'create x as decimal'
    x = @engine.heap.root.children.first
    assert_equal 0.0, x.value

    @engine.parser.run 'put 1.1 into x'
    assert_equal 1.1, x.value

    @engine.parser.run "put '7.1' into x"
    assert_equal 7.1, x.value
  end

end
