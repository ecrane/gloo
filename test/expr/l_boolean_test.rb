require 'test_helper'

class LBooleanTest < BaseTest

  def test_literal_boolean_construction
    e = Gloo::Expr::LBoolean.new( nil )
    assert e
    assert_equal false, e.value
  end

  def test_literal_boolean_construction_with_token
    e = Gloo::Expr::LBoolean.new( true )
    assert_equal true, e.value
    e = Gloo::Expr::LBoolean.new( false )
    assert_equal false, e.value
  end

  def test_is_boolean
    assert Gloo::Expr::LBoolean.boolean?( true )
    assert Gloo::Expr::LBoolean.boolean?( false )
    refute Gloo::Expr::LBoolean.boolean?( 'a' )
  end

  def test_setting_value
    e = Gloo::Expr::LBoolean.new( true )
    assert_equal true, e.value

    e.set_value 'False'
    assert_equal false, e.value

    e.set_value 'tRUe'
    assert_equal true, e.value
  end

  def test_to_string
    e = Gloo::Expr::LBoolean.new( true )
    assert_equal 'true', e.to_s

    e.set_value 'FALSE'
    assert_equal 'false', e.to_s
  end

end
