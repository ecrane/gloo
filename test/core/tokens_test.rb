require "test_helper"

class TokensTest < Minitest::Test
  
  def setup
    @engine = Gloo::App::Engine.new( [ "--quiet" ] )
  end
 
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
    o = Gloo::Core::Tokens.new( "quit" )
    assert o
  end

  def test_creation_of_token_list_with_string
    o = Gloo::Core::Tokens.new( 
      'create thing : "a string with spaces"' )
    assert o
    assert_equal 4, o.token_count
  end
  
  def test_creation_of_token_list_with_string
    o = Gloo::Core::Tokens.new( 
      "create thing : 'a string with spaces'" )
    assert o
    assert_equal 4, o.token_count
  end
  
  def test_tokenize
    o = Gloo::Core::Tokens.new( 
      "create thing as string : 'a string with spaces'" )
    assert o
    assert_equal 6, o.token_count
    assert_equal "create", o.first
    assert_equal "thing", o.second
    assert_equal "as", o.at( 2 )
    assert_equal "string", o.at( 3 )
    assert_equal ":", o.at( 4 )
    assert_equal "'a string with spaces'", o.last
  end

  def test_tokenize
    o = Gloo::Core::Tokens.new( 
      'create thing as string : "a string with spaces"' )
    assert o
    assert_equal 6, o.token_count
    assert_equal "create", o.first
    assert_equal "thing", o.second
    assert_equal "as", o.at( 2 )
    assert_equal "string", o.at( 3 )
    assert_equal ":", o.at( 4 )
    assert_equal '"a string with spaces"', o.last
  end
  
  def test_tokenize_with_quotes
    o = Gloo::Core::Tokens.new( '"a string with spaces"' )
    assert o
    assert_equal 1, o.token_count
    assert_equal '"a string with spaces"', o.first
    assert_equal '"a string with spaces"', o.last
  end
  
  def test_token_count
    o = Gloo::Core::Tokens.new( "quit" )
    assert_equal 1, o.token_count
    o = Gloo::Core::Tokens.new( "" )
    assert_equal 0, o.token_count
    o = Gloo::Core::Tokens.new( "create thing" )
    assert_equal 2, o.token_count
  end
  
  def test_that_list_contains_item
    o = Gloo::Core::Tokens.new( "quit" )
    assert o.tokens
    assert_equal 1, o.tokens.count
  end
  
  def test_the_verb
    o = Gloo::Core::Tokens.new( "quit" )
    assert o
    assert_equal 1, o.token_count
    assert o.verb
    assert_equal "quit", o.verb
  end
  
  def test_first_token
    o = Gloo::Core::Tokens.new( "create thing" )
    assert_equal "create", o.first
  end
  
  def test_last_token
    o = Gloo::Core::Tokens.new( "create thing" )
    assert_equal "thing", o.last
    o = Gloo::Core::Tokens.new( "one" )
    assert_equal "one", o.last
    o = Gloo::Core::Tokens.new( "one two three 4 5" )
    assert_equal "5", o.last
  end
  
  def test_second_token
    o = Gloo::Core::Tokens.new( "create thing" )
    assert_equal "thing", o.second
  end
  
  def test_token_at
    o = Gloo::Core::Tokens.new( "create thing" )
    assert_equal "create", o.at( 0 )
    assert_equal "thing", o.at( 1 )
    o = Gloo::Core::Tokens.new( "one two three 4 5" )
    assert_equal "one", o.at( 0 )
    assert_equal "4", o.at( 3 )
    assert_equal "5", o.at( 4 )
  end
  
  def test_empty_token_list
    o = Gloo::Core::Tokens.new( "" )
    refute o.verb
    refute o.first
    refute o.second
  end
  
  def test_index_of
    o = Gloo::Core::Tokens.new( "create thing" )
    assert_equal 0, o.index_of( "create" )
    assert_equal 0, o.index_of( "Create" )
    assert_equal 0, o.index_of( "CREATE" )
    assert_equal 1, o.index_of( "thing" )
    assert_equal 1, o.index_of( "THING" )
    refute o.index_of( "xyz" )
  end
  
  def test_after_token
    o = Gloo::Core::Tokens.new( "create thing as string" )
    assert_equal "string", o.after_token( "as" )
    assert_equal "string", o.after_token( "AS" )
    o = Gloo::Core::Tokens.new( "AS string" )
    assert_equal "string", o.after_token( "as" )
    assert_equal "string", o.after_token( "AS" )
  end

  def test_before_token
    o = Gloo::Core::Tokens.new( "put 2 + 3 into x" )
    assert_equal 6, o.token_count
    before = o.before_token "into"
    assert_equal 4, before.count
  end
  
end
