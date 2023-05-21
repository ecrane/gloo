require 'test_helper'

class OpTest < BaseTest

  def test_op?
    assert GlooLang::Core::Op.op?( ' + ' )
    assert GlooLang::Core::Op.op?( '+' )
    assert GlooLang::Core::Op.op?( '- ' )
    assert GlooLang::Core::Op.op?( ' *' )
    assert GlooLang::Core::Op.op?( '/' )
    refute GlooLang::Core::Op.op?( 'asdf' )
    refute GlooLang::Core::Op.op?( '++++' )
    refute GlooLang::Core::Op.op?( '23' )
  end

  def test_create_op_plus
    o = GlooLang::Core::Op.create_op( '+' )
    assert o
    assert_same GlooLang::Expr::OpPlus, o.class
  end

  def test_create_op_minus
    o = GlooLang::Core::Op.create_op( '-' )
    assert o
    assert_same GlooLang::Expr::OpMinus, o.class
  end

  def test_create_op_div
    o = GlooLang::Core::Op.create_op( '/' )
    assert o
    assert_same GlooLang::Expr::OpDiv, o.class
  end

  def test_create_op_mult
    o = GlooLang::Core::Op.create_op( '*' )
    assert o
    assert_same GlooLang::Expr::OpMult, o.class
  end

  def test_default_op
    o = GlooLang::Core::Op.default_op
    assert o
    assert_same GlooLang::Expr::OpPlus, o.class
  end

end
