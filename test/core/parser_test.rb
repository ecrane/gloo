require 'test_helper'

class ParserTest < BaseEngineTest

  def test_parser_constrution
    o = Gloo::Core::Parser.new @engine
    assert o
  end

  def test_parse_immediate
    assert @engine.running
    i = @engine.parser.parse_immediate 'quit'
    assert i
  end

  def test_parse_immediate_no_verb
    assert @engine.running
    i = @engine.parser.parse_immediate 'xxxxxyyyyyzzzz'
    refute i
  end

  def test_parser_run
    @engine.parser.run 'show 10 + 3 - 0'
    assert_equal 13, @engine.heap.it.value
  end

  def test_splitting_params_with_no_params
    cmd, params = @engine.parser.split_params 'test'
    assert_equal 'test', cmd
    refute params

    cmd, params = @engine.parser.split_params 'one two three'
    assert_equal 'one two three', cmd
    refute params

    cmd, params = @engine.parser.split_params 'abc)'
    assert_equal 'abc)', cmd
    refute params
  end

  def test_splitting_params_with_params
    cmd, params = @engine.parser.split_params 'test (p)'
    assert_equal 'test', cmd
    assert_equal 'p', params
  end

  def test_splitting_params_leaves_inline_invoke_call_alone
    cmd, params = @engine.parser.split_params 'show invoke( functions.add 3 4 )'
    assert_equal 'show invoke( functions.add 3 4 )', cmd
    refute params
  end

  def test_splitting_params_leaves_inline_shortcut_call_alone
    cmd, params = @engine.parser.split_params 'show ~>( functions.add 3 4 )'
    assert_equal 'show ~>( functions.add 3 4 )', cmd
    refute params
  end

  def test_splitting_params_still_works_with_trailing_call_and_color
    cmd, params = @engine.parser.split_params 'show invoke( functions.add 3 4 ) (blue)'
    assert_equal 'show invoke( functions.add 3 4 )', cmd
    assert_equal 'blue', params
  end

  def test_splitting_params_with_unbalanced_parens_leaves_cmd_alone
    cmd, params = @engine.parser.split_params 'test))'
    assert_equal 'test))', cmd
    refute params
  end

  def test_splitting_params_matches_the_outer_pair_with_nested_parens
    cmd, params = @engine.parser.split_params 'show f( (a) )'
    assert_equal 'show f', cmd
    assert_equal '(a) ', params
  end

end
