require 'test_helper'

class LineSplitterTest < BaseEngineTest

  def test_splitting_a_line
    str = "name type value\n"
    o = Gloo::Persist::LineSplitter.new( str, 0 )
    n, t, v = o.split
    assert_equal 'name', n
    assert_equal 'type', t
    assert_equal 'value', v

    str = "name [type] one two three\n"
    o = Gloo::Persist::LineSplitter.new( str, 0 )
    n, t, v = o.split
    assert_equal 'name', n
    assert_equal 'type', t
    assert_equal 'one two three', v

    str = 'my_string [str] : xyz'
    o = Gloo::Persist::LineSplitter.new( str, 0 )
    n, t, v = o.split
    assert_equal 'my_string', n
    assert_equal 'str', t
    assert_equal 'xyz', v
  end

  def test_untyped_detection
    str = 'my_val : hello'
    o = Gloo::Persist::LineSplitter.new( str, 0 )
    n, t, v = o.split
    assert_equal 'my_val', n
    assert_equal 'untyped', t
  end

  def test_trailing_whitespace_is_kept_on_the_value
    o = Gloo::Persist::LineSplitter.new( "s [string] : hello   \n", 0 )
    n, t, v = o.split
    assert_equal 's', n
    assert_equal 'string', t
    assert_equal 'hello   ', v
    assert_equal ' : hello   ', o.raw_tail
  end

  def test_leading_indentation_is_still_removed
    o = Gloo::Persist::LineSplitter.new( "\t\ts [string] : hi\n", 0 )
    n, = o.split
    assert_equal 's', n
  end

  def test_a_line_with_no_name
    assert_equal [ nil, 'int', '3' ], Gloo::Persist::LineSplitter.new( '[int] : 3', 0 ).split
    assert_equal [ nil, 'string', 'a b' ], Gloo::Persist::LineSplitter.new( '[string] : a b', 0 ).split
    assert_equal [ nil, 'untyped', '3' ], Gloo::Persist::LineSplitter.new( ': 3', 0 ).split
    n, t, v = Gloo::Persist::LineSplitter.new( '  [int] :', 1 ).split
    assert_nil n
    assert_equal 'int', t
    assert_empty v.to_s
  end

  def test_a_type_missing_its_closing_bracket
    o = Gloo::Persist::LineSplitter.new( 'a [int : 3', 0 )
    assert_equal [ 'a', 'int', '3' ], o.split
    assert o.missing_bracket
    assert_equal ' : 3', o.raw_tail

    o = Gloo::Persist::LineSplitter.new( 'a [int', 0 )
    assert_equal [ 'a', 'int', nil ], o.split
    assert o.missing_bracket
  end

  def test_a_bracket_in_the_value_does_not_close_the_type
    o = Gloo::Persist::LineSplitter.new( 'a [string : a ] b', 0 )
    assert_equal [ 'a', 'string', 'a ] b' ], o.split
    assert o.missing_bracket
    assert_equal ' : a ] b', o.raw_tail
  end

  def test_a_closed_type_followed_by_the_colon
    o = Gloo::Persist::LineSplitter.new( 'a [int]: 3', 0 )
    assert_equal [ 'a', 'int', '3' ], o.split
    refute o.missing_bracket
    assert_equal ': 3', o.raw_tail
  end

  def test_a_closed_type_is_not_missing_a_bracket
    o = Gloo::Persist::LineSplitter.new( 'a [int] : 3', 0 )
    o.split
    refute o.missing_bracket
  end

end
