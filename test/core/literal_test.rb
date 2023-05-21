require 'test_helper'

class LiteralTest < BaseTest

  def test_literal_constrution
    o = Gloo::Core::Literal.new( 'string' )
    assert o
    assert_equal 'string', o.value

    o = Gloo::Core::Literal.new( 77 )
    assert o
    assert_equal 77, o.value
  end

  def test_setting_literal_value
    o = Gloo::Core::Literal.new( 'a' )
    assert o
    assert_equal 'a', o.value

    o.set_value 'b'
    assert_equal 'b', o.value

    o.set_value 3
    assert_equal 3, o.value
  end

end
