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

  # Leading zeros and a leading plus are integers; 007 is 7, not octal.
  def test_integer_spellings
    %w[ 007 +5 -12 0 ].each do |s|
      assert Gloo::Expr::LInteger.integer?( s ), "expected #{s} to be an integer"
    end
    %w[ 5. 1,000 1_000 0x1A 2.0 ].each do |s|
      refute Gloo::Expr::LInteger.integer?( s ), "expected #{s} not to be an integer"
    end
  end

end
