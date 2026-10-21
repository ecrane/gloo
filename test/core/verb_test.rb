require 'test_helper'

class VerbTest < BaseEngineTest

  def test_verb_creation
    o = Gloo::Core::Verb.new( @engine, nil )
    assert o
    assert_equal( 0, o.params.count )
  end

  def test_verb_creation_with_params
    o = Gloo::Core::Verb.new( @engine, nil, [ 'one' ] )
    assert o
    assert_equal( 1, o.params.count )
    assert_equal( 'one', o.params.first )
  end

  # ---------------------------------------------------------------------
  #    Verbs that take no object
  # ---------------------------------------------------------------------

  def test_extra_words_empty_for_a_bare_verb
    v = @engine.parser.parse_immediate 'cls'
    assert_equal '', v.extra_words
  end

  def test_extra_words_include_words_and_params
    v = @engine.parser.parse_immediate 'cls now ( 3 )'
    assert_equal 'now 3', v.extra_words
  end

  def test_extra_words_with_no_tokens
    v = Gloo::Verbs::Help.new( @engine, nil )
    assert_equal '', v.extra_words
  end

  # ---------------------------------------------------------------------
  #    A trailing ( expr ) as the last argument
  # ---------------------------------------------------------------------

  def test_take_evaluated_arg_without_params_changes_nothing
    v = @engine.parser.parse_immediate 'load lib md'
    assert v.take_evaluated_arg
    assert_equal 3, v.tokens.token_count
    assert_equal 'md', v.tokens.last
  end

  def test_take_evaluated_arg_adds_the_value_as_the_last_token
    v = @engine.parser.parse_immediate "load lib ( 'm' 'd' )"
    assert v.take_evaluated_arg
    assert_equal 3, v.tokens.token_count
    assert_equal 'md', v.tokens.last
    assert_nil v.params
  end

  def test_take_evaluated_arg_works_without_spaces_in_the_parens
    @engine.parser.run 'create n as string : md'
    v = @engine.parser.parse_immediate 'load lib (n)'
    assert v.take_evaluated_arg
    assert_equal 'md', v.tokens.last
  end

  def test_take_evaluated_arg_keeps_a_value_with_spaces_as_one_token
    v = @engine.parser.parse_immediate "load ( '/a b' '/c.gloo' )"
    assert v.take_evaluated_arg
    assert_equal 2, v.tokens.token_count
    assert_equal '/a b/c.gloo', v.tokens.last
  end

  def test_take_evaluated_arg_reports_an_expression_that_fails
    v = @engine.parser.parse_immediate 'load lib ( no_such_obj )'
    refute v.take_evaluated_arg
    assert @engine.error?
    assert_equal 2, v.tokens.token_count
  end

end
