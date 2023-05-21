require 'test_helper'

class LIntegerTest < BaseTest

  def test_literal_integer_construction
    e = Gloo::Expr::LInteger.new( nil )
    assert e
    assert_equal 0, e.value
  end

  def test_literal_integer_construction_with_token
    token = 23
    e = Gloo::Expr::LInteger.new( token )
    assert e
    assert_equal 23, e.value
  end

  def test_is_integer
    assert Gloo::Expr::LInteger.integer?( '23' )
    refute Gloo::Expr::LInteger.integer?( 'a' )
  end

  def test_setting_value
    e = Gloo::Expr::LInteger.new( 32 )
    assert_equal 32, e.value

    e.set_value 0
    assert_equal 0, e.value
  end

  def test_to_string
    e = Gloo::Expr::LInteger.new( 43 )
    assert_equal '43', e.to_s

    e.set_value 100
    assert_equal '100', e.to_s
  end

end
