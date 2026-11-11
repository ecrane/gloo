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

  # ---------------------------------------------------------------------
  #    A ( expr ) group at an object-path position
  # ---------------------------------------------------------------------

  #
  # Parse a command after creating p, a string holding the path t.s.
  #
  def parse_with_p( cmd )
    @engine.parser.run "create p as string : 't.s'"
    return @engine.parser.parse_immediate( cmd )
  end

  def test_take_path_arg_without_a_group_changes_nothing
    v = parse_with_p 'tell t.s to run'
    assert v.take_path_arg( 1 )
    assert_equal %w[tell t.s to run], v.tokens.tokens
  end

  def test_take_path_arg_works_out_a_group_mid_line
    v = parse_with_p 'tell ( p ) to run'
    assert v.take_path_arg( 1 )
    assert_equal %w[tell t.s to run], v.tokens.tokens
  end

  def test_take_path_arg_works_out_a_group_without_spaces
    v = parse_with_p 'tell (p) to run'
    assert v.take_path_arg( 1 )
    assert_equal %w[tell t.s to run], v.tokens.tokens
  end

  def test_take_path_arg_works_out_a_built_path
    v = parse_with_p "tell ('t.' 's') to run"
    assert v.take_path_arg( 1 )
    assert_equal %w[tell t.s to run], v.tokens.tokens
  end

  def test_take_path_arg_works_out_a_trailing_group
    v = parse_with_p "put 1 into ( 't.' 's' )"
    assert v.take_path_arg( 'into' )
    assert_equal %w[put 1 into t.s], v.tokens.tokens
    assert_nil v.params
  end

  def test_take_path_arg_works_out_a_trailing_group_as_the_only_argument
    v = parse_with_p 'list ( p )'
    assert v.take_path_arg( 1 )
    assert_equal %w[list t.s], v.tokens.tokens
    assert_nil v.params
  end

  def test_take_path_arg_leaves_message_params_alone
    v = parse_with_p 'tell ( p ) to run ( 1 )'
    assert v.take_path_arg( 1 )
    assert_equal %w[tell t.s to run], v.tokens.tokens
    assert_equal [ '1' ], v.params.tokens
  end

  def test_take_path_arg_leaves_a_trailing_group_that_is_not_the_path
    v = parse_with_p 'tell t.s to run ( 1 )'
    assert v.take_path_arg( 1 )
    assert_equal %w[tell t.s to run], v.tokens.tokens
    assert_equal [ '1' ], v.params.tokens
  end

  def test_take_path_arg_leaves_a_value_group_alone
    v = parse_with_p 'create x as string : ( p )'
    assert v.take_path_arg( 1 )
    assert_equal %w[create x as string :], v.tokens.tokens
    assert_equal [ 'p' ], v.params.tokens
  end

  def test_take_path_arg_at_two_positions
    @engine.parser.run "create q as string : 'x'"
    v = parse_with_p 'move ( p ) to ( q )'
    assert v.take_path_arg( 1 )
    assert v.take_path_arg( 'to' )
    assert_equal %w[move t.s to x], v.tokens.tokens
    assert_nil v.params
  end

  def test_take_path_arg_with_no_such_keyword_changes_nothing
    v = parse_with_p 'put 1 ( p )'
    assert v.take_path_arg( 'into' )
    assert_equal %w[put 1], v.tokens.tokens
    assert_equal [ 'p' ], v.params.tokens
  end

  def test_take_path_arg_keeps_a_value_with_spaces_as_one_token
    v = parse_with_p "tell ( 'a b' '.c' ) to run"
    assert v.take_path_arg( 1 )
    assert_equal [ 'tell', 'a b.c', 'to', 'run' ], v.tokens.tokens
  end

  def test_take_path_arg_skips_a_paren_inside_quotes
    v = parse_with_p "tell ( 'x)' '.y' ) to run"
    assert v.take_path_arg( 1 )
    assert_equal [ 'tell', 'x).y', 'to', 'run' ], v.tokens.tokens
  end

  def test_take_path_arg_reports_an_expression_that_fails
    v = parse_with_p 'tell ( no_such_obj ) to run'
    refute v.take_path_arg( 1 )
    assert @engine.error?
    assert_equal %w[tell ( no_such_obj ) to run], v.tokens.tokens
  end

  def test_take_path_arg_reports_a_trailing_expression_that_fails
    v = parse_with_p 'list ( no_such_obj )'
    refute v.take_path_arg( 1 )
    assert @engine.error?
    assert_equal %w[list ( no_such_obj )], v.tokens.tokens
  end

  def test_take_path_arg_leaves_an_unclosed_group
    v = parse_with_p 'tell ( p to run'
    assert v.take_path_arg( 1 )
    assert_equal %w[tell ( p to run], v.tokens.tokens
  end

  def test_take_path_arg_reports_a_blank_path
    @engine.parser.run 'create b as string'
    v = @engine.parser.parse_immediate 'tell ( b ) to run'
    refute v.take_path_arg( 1 )
    assert_equal "Object path '( b )' is blank.", @engine.heap.error.value
  end

  def test_take_path_arg_reports_a_blank_trailing_path
    @engine.parser.run 'create b as string'
    v = @engine.parser.parse_immediate 'list ( b )'
    refute v.take_path_arg( 1 )
    assert_equal "Object path '( b )' is blank.", @engine.heap.error.value
  end

  def test_take_path_arg_with_no_tokens
    v = Gloo::Core::Verb.new( @engine, nil )
    assert v.take_path_arg( 1 )
  end

end
