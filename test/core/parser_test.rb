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

  # -------------------------------------------------------------------
  #   Inline trailing comments
  # -------------------------------------------------------------------

  def test_strip_comment_removes_a_trailing_comment
    p = @engine.parser
    assert_equal 'show it', p.strip_comment( 'show it # trailing comment' )
    assert_equal 'show 3 + 4', p.strip_comment( 'show 3 + 4 # math' )
  end

  def test_strip_comment_leaves_a_plain_command_alone
    p = @engine.parser
    assert_equal 'show it', p.strip_comment( 'show it' )
  end

  def test_strip_comment_keeps_a_hash_inside_quotes
    p = @engine.parser
    assert_equal "show 'a # b'", p.strip_comment( "show 'a # b'" )
    assert_equal 'show "a # b"', p.strip_comment( 'show "a # b"' )
  end

  def test_strip_comment_keeps_a_hash_glued_to_text
    p = @engine.parser
    assert_equal 'create u as uri : http://x?id=1#frag',
                 p.strip_comment( 'create u as uri : http://x?id=1#frag' )
  end

  def test_strip_comment_after_a_quoted_string
    p = @engine.parser
    assert_equal "show 'literal'", p.strip_comment( "show 'literal' # note" )
  end

  def test_strip_comment_on_a_whole_line_comment
    assert_equal '', @engine.parser.strip_comment( '# just a comment' )
  end

  def test_parse_immediate_ignores_a_trailing_comment
    i = @engine.parser.parse_immediate 'show 3 + 4 # this is math'
    i.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_parse_immediate_returns_nil_for_a_comment_only_line
    refute @engine.parser.parse_immediate '# nothing to run here'
    refute @engine.error?
  end

  def test_show_it_with_a_trailing_comment_when_it_is_a_boolean
    @engine.parser.run 'create s as string : hello'
    @engine.parser.run 'check s for blank?'
    @engine.parser.run 'show it # should print false, not blank'
    assert_equal false, @engine.heap.it.value
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
