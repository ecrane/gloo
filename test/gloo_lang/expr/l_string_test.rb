require 'test_helper'

class LStringTest < BaseTest

  def test_literal_string_construction
    e = GlooLang::Expr::LString.new( nil )
    assert e
    refute e.value
  end

  def test_literal_string_construction_with_token
    token = '"test"'
    e = GlooLang::Expr::LString.new( token )
    assert e
    assert_equal 'test', e.value
  end

  def test_literal_string_construction_with_token_leading_space
    token = '" space"'
    e = GlooLang::Expr::LString.new( token )
    assert e
    assert_equal ' space', e.value
  end

  def test_is_string
    assert GlooLang::Expr::LString.string?( '"one"' )
    assert GlooLang::Expr::LString.string?( '" two"' )
    refute GlooLang::Expr::LString.string?( '1' )
  end

  def test_setting_value
    e = GlooLang::Expr::LString.new( '"boo"' )
    assert_equal 'boo', e.value

    e.set_value '"abc"'
    assert_equal 'abc', e.value
  end

  def test_to_string
    e = GlooLang::Expr::LString.new( '"the red dog"' )
    assert_equal 'the red dog', e.to_s

    e.set_value "\"bee's knees\""
    assert_equal "bee's knees", e.to_s
  end

end
