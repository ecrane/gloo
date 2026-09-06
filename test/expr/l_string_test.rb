require 'test_helper'

class LStringTest < BaseTest

  def test_literal_string_construction
    e = Gloo::Expr::LString.new( nil )
    assert e
    refute e.value
  end

  def test_literal_string_construction_with_token
    token = '"test"'
    e = Gloo::Expr::LString.new( token )
    assert e
    assert_equal 'test', e.value
  end

  def test_literal_string_construction_with_token_leading_space
    token = '" space"'
    e = Gloo::Expr::LString.new( token )
    assert e
    assert_equal ' space', e.value
  end

  def test_is_string
    assert Gloo::Expr::LString.string?( '"one"' )
    assert Gloo::Expr::LString.string?( '" two"' )
    refute Gloo::Expr::LString.string?( '1' )
  end

  def test_setting_value
    e = Gloo::Expr::LString.new( '"boo"' )
    assert_equal 'boo', e.value

    e.set_value '"abc"'
    assert_equal 'abc', e.value
  end

  def test_to_string
    e = Gloo::Expr::LString.new( '"the red dog"' )
    assert_equal 'the red dog', e.to_s

    e.set_value "\"bee's knees\""
    assert_equal "bee's knees", e.to_s
  end

  def test_single_quoted_literal_keeps_embedded_double_quotes
    e = Gloo::Expr::LString.new( %q('{"x":1}') )
    assert_equal '{"x":1}', e.value
  end

  def test_double_quoted_literal_keeps_embedded_single_quote
    e = Gloo::Expr::LString.new( %q("it's here") )
    assert_equal "it's here", e.value
  end

  def test_double_quoted_literal_unescapes_an_escaped_double_quote
    e = Gloo::Expr::LString.new( '"say \\"hi\\""' )
    assert_equal 'say "hi"', e.value
  end

  def test_single_quoted_literal_unescapes_an_escaped_single_quote
    e = Gloo::Expr::LString.new( "'don\\'t'" )
    assert_equal "don't", e.value
  end

  def test_strip_quotes_returns_input_when_not_quoted
    assert_equal 'plain', Gloo::Expr::LString.strip_quotes( 'plain' )
  end

end
