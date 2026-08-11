require 'test_helper'

class TokensTest < BaseTest

  def test_tokenize_with_quotes_trailing_space
    o = Gloo::Core::Tokens.new( '"space "' )
    assert o
    assert_equal 1, o.token_count
    assert_equal '"space "', o.first
    assert_equal '"space "', o.last
  end

  def test_tokenize_with_quotes_leading_space
    o = Gloo::Core::Tokens.new( '" space"' )
    assert o
    assert_equal 1, o.token_count
    assert_equal '" space"', o.first
    assert_equal '" space"', o.last
  end

  def test_creation_of_token_list
    o = Gloo::Core::Tokens.new( 'quit' )
    assert o
  end

  def test_creation_of_token_list_with_string
    str = 'create thing : "a string with spaces"'
    o = Gloo::Core::Tokens.new( str )
    assert o
    assert_equal 4, o.token_count
  end

  def test_tokenize
    str = 'create thing as string : "a string with spaces"'
    o = Gloo::Core::Tokens.new( str )
    assert o
    assert_equal 6, o.token_count
    assert_equal 'create', o.first
    assert_equal 'thing', o.second
    assert_equal 'as', o.at( 2 )
    assert_equal 'string', o.at( 3 )
    assert_equal ':', o.at( 4 )
    assert_equal '"a string with spaces"', o.last
  end

  def test_tokenize_with_quotes
    str = '"a string with spaces"'
    o = Gloo::Core::Tokens.new( str )
    assert o
    assert_equal 1, o.token_count
    assert_equal '"a string with spaces"', o.first
    assert_equal '"a string with spaces"', o.last
  end

  def test_token_count
    o = Gloo::Core::Tokens.new( 'quit' )
    assert_equal 1, o.token_count
    o = Gloo::Core::Tokens.new( '' )
    assert_equal 0, o.token_count
    o = Gloo::Core::Tokens.new( 'create thing' )
    assert_equal 2, o.token_count
  end

  def test_that_list_contains_item
    o = Gloo::Core::Tokens.new( 'quit' )
    assert o.tokens
    assert_equal 1, o.tokens.count
  end

  def test_the_verb
    o = Gloo::Core::Tokens.new( 'quit' )
    assert o
    assert_equal 1, o.token_count
    assert o.verb
    assert_equal 'quit', o.verb
  end

  def test_empty_params
    o = Gloo::Core::Tokens.new( 'quit' )
    assert o
    assert_equal [], o.params
  end

  def test_one_param
    o = Gloo::Core::Tokens.new( 'show me' )
    assert o
    assert_equal 1, o.params.count
    assert_equal 'me', o.params.first
  end

  def test_two_param
    o = Gloo::Core::Tokens.new( 'show me more' )
    assert o
    assert_equal 2, o.params.count
    assert_equal 'me', o.params.first
    assert_equal 'more', o.params.last
  end

  def test_first_token
    o = Gloo::Core::Tokens.new( 'create thing' )
    assert_equal 'create', o.first
  end

  def test_last_token
    o = Gloo::Core::Tokens.new( 'create thing' )
    assert_equal 'thing', o.last
    o = Gloo::Core::Tokens.new( 'one' )
    assert_equal 'one', o.last
    o = Gloo::Core::Tokens.new( 'one two three 4 5' )
    assert_equal '5', o.last
  end

  def test_second_token
    o = Gloo::Core::Tokens.new( 'create thing' )
    assert_equal 'thing', o.second
  end

  def test_token_at_wrong_index
    o = Gloo::Core::Tokens.new( 'create thing' )
    refute o.at( 13 )
  end

  def test_token_at
    o = Gloo::Core::Tokens.new( 'create thing' )
    assert_equal 'create', o.at( 0 )
    assert_equal 'thing', o.at( 1 )

    o = Gloo::Core::Tokens.new( 'one two three 4 5' )
    assert_equal 'one', o.at( 0 )
    assert_equal '4', o.at( 3 )
    assert_equal '5', o.at( 4 )
  end

  def test_empty_token_list
    o = Gloo::Core::Tokens.new( '' )
    refute o.verb
    refute o.first
    refute o.second
  end

  def test_index_of
    o = Gloo::Core::Tokens.new( 'create thing' )
    assert_equal 0, o.index_of( 'create' )
    assert_equal 0, o.index_of( 'Create' )
    assert_equal 0, o.index_of( 'CREATE' )
    assert_equal 1, o.index_of( 'thing' )
    assert_equal 1, o.index_of( 'THING' )
    refute o.index_of( 'xyz' )
  end

  def test_after_token
    o = Gloo::Core::Tokens.new( 'create thing as string' )
    assert_equal 'string', o.after_token( 'as' )
    assert_equal 'string', o.after_token( 'AS' )
    o = Gloo::Core::Tokens.new( 'AS string' )
    assert_equal 'string', o.after_token( 'as' )
    assert_equal 'string', o.after_token( 'AS' )
  end

  def test_tokens_with_decimal
    o = Gloo::Core::Tokens.new( '= 2.3 + 3.4' )
    assert_equal 4, o.token_count
  end

  def test_before_token
    o = Gloo::Core::Tokens.new( 'put 2 + 3 into x' )
    assert_equal 6, o.token_count
    before = o.before_token 'into'
    assert_equal 4, before.count
  end

  def test_tokens_after
    o = Gloo::Core::Tokens.new( 'if true then show 2 + 5' )
    arr = o.tokens_after( 'then' )
    assert arr
    assert_equal 4, arr.count
    assert_equal 'show', arr.first
  end

  def test_expr_after
    o = Gloo::Core::Tokens.new( 'if true then show 2 + 5' )
    str = o.expr_after( 'then' )
    assert str
    assert_equal 'show 2 + 5', str
  end

  def test_tokenize_with_inline_invoke_call
    o = Gloo::Core::Tokens.new( 'show invoke( functions.add 3 4 )' )
    assert_equal 2, o.token_count
    assert_equal 'show', o.first
    assert_equal 'invoke( functions.add 3 4 )', o.second
  end

  def test_tokenize_with_inline_shortcut_call
    o = Gloo::Core::Tokens.new( 'show ~>( functions.add 3 4 )' )
    assert_equal 2, o.token_count
    assert_equal '~>( functions.add 3 4 )', o.second
  end

  def test_tokenize_with_inline_call_mid_expression
    o = Gloo::Core::Tokens.new( 'put invoke( functions.add 3 4 ) into x' )
    assert_equal 4, o.token_count
    assert_equal 'put', o.first
    assert_equal 'invoke( functions.add 3 4 )', o.at( 1 )
    assert_equal 'into', o.at( 2 )
    assert_equal 'x', o.at( 3 )
  end

  def test_tokenize_with_inline_call_containing_quoted_arg
    o = Gloo::Core::Tokens.new( 'show invoke( functions.greet "Bob Smith" )' )
    assert_equal 2, o.token_count
    assert_equal 'invoke( functions.greet "Bob Smith" )', o.second
  end

  def test_tokenize_does_not_treat_a_word_ending_in_invoke_as_a_call
    o = Gloo::Core::Tokens.new( 'show reinvoke( x )' )
    assert_equal 4, o.token_count
    assert_equal 'reinvoke(', o.at( 1 )
  end

  def test_tokenize_with_unclosed_call_falls_back_to_plain_tokens
    o = Gloo::Core::Tokens.new( 'show invoke( functions.add 3 4' )
    assert_equal 5, o.token_count
    assert_equal 'invoke(', o.at( 1 )
  end

end
