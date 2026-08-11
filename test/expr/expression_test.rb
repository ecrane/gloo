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

  def test_inline_invoke_call_as_whole_expression
    @engine.parser.run 'load ctrl/invoke'
    o = Gloo::Core::Tokens.new( 'invoke( add 3 4 )' )
    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    assert_equal 7, e.evaluate
  end

  def test_inline_shortcut_call_as_whole_expression
    @engine.parser.run 'load ctrl/invoke'
    o = Gloo::Core::Tokens.new( '~>( add 3 4 )' )
    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    assert_equal 7, e.evaluate
  end

  def test_inline_invoke_call_combined_with_operator
    @engine.parser.run 'load ctrl/invoke'
    o = Gloo::Core::Tokens.new( '"Total: " + invoke( add 3 4 )' )
    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    assert_equal 'Total: 7', e.evaluate
  end

  def test_inline_invoke_call_with_quoted_arg
    @engine.parser.run 'load ctrl/invoke'
    o = Gloo::Core::Tokens.new( 'invoke( greet "Bob Smith" )' )
    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    assert_equal 'Hi, Bob Smith', e.evaluate
  end

  def test_inline_invoke_call_error_propagates
    @engine.parser.run 'load ctrl/invoke'
    o = Gloo::Core::Tokens.new( 'invoke( no.such.function )' )
    e = Gloo::Expr::Expression.new( @engine, o.tokens )
    result = e.evaluate
    assert_nil result
    assert @engine.error?
  end

end
