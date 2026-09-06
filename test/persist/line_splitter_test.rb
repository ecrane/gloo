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

end
