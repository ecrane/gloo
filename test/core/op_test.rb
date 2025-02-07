require 'test_helper'

class OpTest < BaseTest

  def test_op?
    assert Gloo::Core::Op.op?( ' + ' )
    assert Gloo::Core::Op.op?( '+' )
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

end
