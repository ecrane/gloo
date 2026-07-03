require 'test_helper'

class LDecimalTest < BaseTest
  
  def test_literal_decimal_construction
    e = Gloo::Expr::LDecimal.new( nil )
    assert e
    assert_equal 0.0, e.value
  end

  def test_literal_decimal_construction_with_token
    token = 31.7
    e = Gloo::Expr::LDecimal.new( token )
    assert e
    assert_equal 31.7, e.value
  end

  def test_is_decimal
    assert Gloo::Expr::LDecimal.decimal?( '23.2' )
    assert Gloo::Expr::LDecimal.decimal?( '0.0' )
    assert Gloo::Expr::LDecimal.decimal?( '-1.23' )
    assert Gloo::Expr::LDecimal.decimal?( '0.009' )

    refute Gloo::Expr::LDecimal.decimal?( 'a' )
    refute Gloo::Expr::LDecimal.decimal?( '1' )
    refute Gloo::Expr::LDecimal.decimal?( '0' )
  end

  def test_setting_value
    e = Gloo::Expr::LDecimal.new( 2213.985 )
    assert_equal 2213.985, e.value

    e.set_value 1.1
    assert_equal 1.1, e.value
  end

  def test_to_string
    e = Gloo::Expr::LDecimal.new( 19.43 )
    assert_equal '19.43', e.to_s

    e.set_value 10.0
    assert_equal '10.0', e.to_s
  end

end
