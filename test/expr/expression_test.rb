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

  def test_missing_middle_of_path_is_reported
    expr = Gloo::Expr::Expression.new( @engine, [ 'no.such.obj' ] )
    assert_nil expr.evaluate
    assert @engine.error?
    assert_equal "Object 'no.such.obj' was not found.", @engine.heap.error.value
    assert_equal 1, @engine.heap.error.error_count
  end

  def test_missing_object_is_reported
    expr = Gloo::Expr::Expression.new( @engine, [ 'nope' ] )
    assert_nil expr.evaluate
    assert_equal "Object 'nope' was not found.", @engine.heap.error.value
  end

  def test_missing_child_of_existing_object_is_reported
    @engine.parser.run 'create c as can'
    @engine.heap.error.clear
    expr = Gloo::Expr::Expression.new( @engine, [ 'c.nope' ] )
    assert_nil expr.evaluate
    assert_equal "Object 'c.nope' was not found.", @engine.heap.error.value
  end

  def test_missing_object_error_uses_the_path_as_written
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.s as script : "show ^.nope"'
    @engine.parser.run 'run c.s'
    assert_equal "Object '^.nope' was not found.", @engine.heap.error.value
  end

  def test_named_color_is_not_an_error
    expr = Gloo::Expr::Expression.new( @engine, [ 'red' ] )
    assert_equal 'red', expr.evaluate
    refute @engine.error?
  end

  def test_operator_missing_a_value_is_reported_and_left_out
    [ [ %w[1 +], 1 ], [ %w[+ 1], 1 ], [ %w[1 + + 2], 3 ] ].each do |tokens, value|
      @engine.heap.error.clear
      expr = Gloo::Expr::Expression.new( @engine, tokens )
      assert_equal value, expr.evaluate
      assert_equal "Operator '+' is missing a value.", @engine.heap.error.value
      assert_equal Gloo::Core::Error::SYNTAX, @engine.heap.error.kind
    end
  end

  def test_operator_that_cant_be_used_with_the_value_is_an_error
    expr = Gloo::Expr::Expression.new( @engine, [ 'true', '-', '1' ] )
    assert_nil expr.evaluate
    assert_equal "Operator '-' can't be used with 'true'.", @engine.heap.error.value
    assert_equal Gloo::Core::Error::RUNTIME, @engine.heap.error.kind
  end

  def test_text_that_is_not_a_number_warns_and_is_zero_in_math
    warnings = capture_warnings do
      expr = Gloo::Expr::Expression.new( @engine, [ "'a'", '-', '1' ] )
      assert_equal( -1, expr.evaluate )
    end
    assert_equal [ "'a' is not a number; using 0." ], warnings
    refute @engine.error?
  end

  def test_missing_value_is_not_reported_twice
    expr = Gloo::Expr::Expression.new( @engine, [ 'no.such.obj', '-', '1' ] )
    assert_nil expr.evaluate
    assert_equal 1, @engine.heap.error.error_count
  end

  # In an expression, every spelling works out to its value.
  def test_decimal_spellings
    { '2.50 * 2' => 5.0, '1.0e3 + 0' => 1000.0, '.5 + 0' => 0.5,
      '0.0000001 * 10' => 0.000001, '-.5 + 1' => 0.5 }.each do |expr, value|
      @engine.parser.run "eval #{expr}"
      assert_in_delta value, @engine.heap.it.value, 1e-12, expr
      refute @engine.error?, expr
    end
  end

  def test_integer_spellings
    @engine.parser.run 'eval 007 + 1'
    assert_equal 8, @engine.heap.it.value
    @engine.parser.run 'eval +5 + 0'
    assert_equal 5, @engine.heap.it.value
  end

  # Work out the expression written in the text.
  def eval_text( text )
    return Gloo::Expr::Expression.new( @engine, Gloo::Core::Tokens.new( text ).tokens ).evaluate
  end

  def test_a_group_is_worked_out_first
    assert_equal 14, eval_text( '2 * ( 3 + 4 )' )
    assert_equal 9, eval_text( '( 1 + 2 ) * 3' )
    assert_equal 7, eval_text( '( 3 + 4 )' )
  end

  def test_groups_nest
    assert_equal 12, eval_text( '2 * ( 3 * ( 1 + 1 ) )' )
    assert_equal 21, eval_text( '( ( 1 + 2 ) * ( 3 + 4 ) )' )
  end

  def test_parens_can_touch_the_values
    assert_equal 7, eval_text( '(3 + 4)' )
    assert_equal 21, eval_text( '((1 + 2) * (3 + 4))' )
  end

  def test_a_group_with_text
    assert_equal 'a3', eval_text( "'a' + ( 1 + 2 )" )
  end

  def test_parens_in_quoted_text_are_text
    assert_equal 'a (b)', eval_text( "'a (b)'" )
    assert_equal 'a)b', eval_text( "( 'a)' + 'b' )" )
  end

  def test_still_left_to_right_outside_groups
    assert_equal 20, eval_text( '2 + 3 * 4' )
    assert_equal 14, eval_text( '2 + ( 3 * 4 )' )
  end

  def test_an_empty_group_is_a_syntax_error
    @engine.heap.error.clear
    assert_nil eval_text( '( )' )
    assert_equal Gloo::Expr::Expression::EMPTY_GROUP_ERR, @engine.heap.error.value
    assert_equal Gloo::Core::Error::SYNTAX, @engine.heap.error.kind
  end

  def test_an_unclosed_group_runs_to_the_end
    assert_equal 3, eval_text( '( 1 + 2' )
  end

  def test_a_stray_close_paren_is_left_out
    assert_equal 3, eval_text( '1 + 2 )' )
  end

end
