require 'test_helper'

class OpTest < BaseTest

  def test_op?
    assert Gloo::Core::Op.op?( ' + ' )
    assert Gloo::Core::Op.op?( '+' )
    assert Gloo::Core::Op.op?( 'and' )
    assert Gloo::Core::Op.op?( '- ' )
    assert Gloo::Core::Op.op?( ' *' )
    assert Gloo::Core::Op.op?( '/' )
    assert Gloo::Core::Op.op?( '=' )
    assert Gloo::Core::Op.op?( '!=' )
    assert Gloo::Core::Op.op?( '>' )
    assert Gloo::Core::Op.op?( '<' )
    assert Gloo::Core::Op.op?( '>=' )
    assert Gloo::Core::Op.op?( '<=' )

    refute Gloo::Core::Op.op?( ' ' )
    refute Gloo::Core::Op.op?( 'asdf' )
    refute Gloo::Core::Op.op?( '++++' )
    refute Gloo::Core::Op.op?( '23' )
  end

  def test_create_op_plus
    o = Gloo::Core::Op.create_op( '+' )
    assert o
    assert_same Gloo::Expr::OpPlus, o.class
  end

  def test_create_op_minus
    o = Gloo::Core::Op.create_op( '-' )
    assert o
    assert_same Gloo::Expr::OpMinus, o.class
  end

  def test_create_op_div
    o = Gloo::Core::Op.create_op( '/' )
    assert o
    assert_same Gloo::Expr::OpDiv, o.class
  end

  def test_create_op_mult
    o = Gloo::Core::Op.create_op( '*' )
    assert o
    assert_same Gloo::Expr::OpMult, o.class
  end

  def test_default_op
    o = Gloo::Core::Op.default_op
    assert o
    assert_same Gloo::Expr::OpPlus, o.class
  end

  def test_create_op_eq
    o = Gloo::Core::Op.create_op( '=' )
    assert o
    assert_same Gloo::Expr::OpEq, o.class
  end

  def test_create_op_ineq
    o = Gloo::Core::Op.create_op( '!=' )
    assert o
    assert_same Gloo::Expr::OpIneq, o.class
  end

  def test_create_op_gt
    o = Gloo::Core::Op.create_op( '>' )
    assert o
    assert_same Gloo::Expr::OpGt, o.class
  end

  def test_create_op_lt
    o = Gloo::Core::Op.create_op( '<' )
    assert o
    assert_same Gloo::Expr::OpLt, o.class
  end

  def test_create_op_gteq
    o = Gloo::Core::Op.create_op( '>=' )
    assert o
    assert_same Gloo::Expr::OpGteq, o.class
  end

  def test_create_op_lteq
    o = Gloo::Core::Op.create_op( '<=' )
    assert o
    assert_same Gloo::Expr::OpLteq, o.class
  end

  def test_promote_two_integers_stays_integers
    assert_equal [ 1, 2 ], Gloo::Expr::OpPlus.new.promote( 1, 2 )
    assert_kind_of Integer, Gloo::Expr::OpPlus.new.promote( 1, 2 ).first
  end

  def test_promote_integer_and_decimal_gives_decimals
    assert_equal [ 1.0, 2.5 ], Gloo::Expr::OpPlus.new.promote( 1, 2.5 )
    assert_equal [ 2.5, 1.0 ], Gloo::Expr::OpPlus.new.promote( 2.5, 1 )
    Gloo::Expr::OpPlus.new.promote( 1, 2.5 ).each { |n| assert_kind_of Float, n }
  end

  def test_promote_is_nil_unless_both_are_numbers
    assert_nil Gloo::Expr::OpPlus.new.promote( 1, "2" )
    assert_nil Gloo::Expr::OpPlus.new.promote( "1", 2 )
    assert_nil Gloo::Expr::OpPlus.new.promote( true, 2 )
  end

  def test_compare_text_ignores_case_first
    op = Gloo::Expr::OpLt.new
    assert_equal( -1, op.compare_text( "abc", "abd" ) )
    assert_equal( -1, op.compare_text( "apple", "Banana" ) )
    assert_equal 1, op.compare_text( "b", "A" )
  end

  def test_compare_text_puts_capital_first_on_a_tie
    op = Gloo::Expr::OpLt.new
    assert_equal( -1, op.compare_text( "A", "a" ) )
    assert_equal( -1, op.compare_text( "Banana", "banana" ) )
    assert_equal 1, op.compare_text( "banana", "Banana" )
  end

  def test_compare_text_is_equal_only_when_exact
    op = Gloo::Expr::OpLt.new
    assert_equal 0, op.compare_text( "x", "x" )
    refute_equal 0, op.compare_text( "x", "X" )
  end

  def test_compare_text_is_nil_unless_both_are_strings
    op = Gloo::Expr::OpLt.new
    assert_nil op.compare_text( "5", 10 )
    assert_nil op.compare_text( 5, "10" )
  end

end
