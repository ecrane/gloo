require 'test_helper'

class CallTest < BaseEngineTest

  def test_call_recognizes_invoke_form
    assert Gloo::Expr::Call.call?( 'invoke( add 3 4 )' )
  end

  def test_call_recognizes_shortcut_form
    assert Gloo::Expr::Call.call?( '~>( add 3 4 )' )
  end

  def test_call_rejects_plain_reference
    refute Gloo::Expr::Call.call?( 'functions.add' )
  end

  def test_call_rejects_non_string
    refute Gloo::Expr::Call.call?( nil )
    refute Gloo::Expr::Call.call?( 42 )
  end

  def test_parses_target_and_args
    call = Gloo::Expr::Call.new( @engine, 'invoke( add 3 4 )' )
    assert_equal 'add', call.target
    assert_equal [ '3', '4' ], call.arg_tokens
  end

  def test_parses_target_with_no_args
    call = Gloo::Expr::Call.new( @engine, 'invoke( f )' )
    assert_equal 'f', call.target
    assert_equal [], call.arg_tokens
  end

  def test_parses_quoted_arg_as_one_token
    call = Gloo::Expr::Call.new( @engine, 'invoke( greet "Bob Smith" )' )
    assert_equal 'greet', call.target
    assert_equal [ '"Bob Smith"' ], call.arg_tokens
  end

  def test_value_invokes_the_function
    @engine.parser.run 'load ctrl/invoke'
    call = Gloo::Expr::Call.new( @engine, 'invoke( add 3 4 )' )
    assert_equal 7, call.value
  end

  def test_value_returns_nil_and_reports_error_on_failure
    @engine.parser.run 'load ctrl/invoke'
    call = Gloo::Expr::Call.new( @engine, 'invoke( no.such.function )' )
    assert_nil call.value
    assert @engine.error?
  end

end
