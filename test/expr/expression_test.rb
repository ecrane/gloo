require 'test_helper'

class ExpressionTest < BaseEngineTest

  def test_expression_construction
    e = Gloo::Expr::Expression.new( @engine, nil )
    assert e
  end

  def test_tokenizing_boolean
    o = Gloo::Core::Tokens.new( 'TRUE' )
    assert o
    assert_equal 1, o.token_count

    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    assert e

    result = e.evaluate
    assert_equal true, result
  end

  def test_tokenizing_integers
    o = Gloo::Core::Tokens.new( '7 - 4' )
    assert o
    assert_equal 3, o.token_count

    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    assert e

    result = e.evaluate
    assert_equal 3, result
  end

  def test_tokenizing_decimals
    o = Gloo::Core::Tokens.new( '2.3 + 3.4' )
    assert o
    assert_equal 3, o.token_count

    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    assert e

    result = e.evaluate
    assert_equal 5.7, result.round( 1 )
  end

  def test_tokenizing_strings
    o = Gloo::Core::Tokens.new( '"hello" + " world"' )
    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    result = e.evaluate
    assert_equal 'hello world', result
  end

  def test_object_reference_resolution
    @engine.parser.run 'create x as int : 10'
    @engine.parser.run 'create y as int : 5'
    o = Gloo::Core::Tokens.new( 'x + y' )
    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    result = e.evaluate
    assert_equal 15, result
  end

end
