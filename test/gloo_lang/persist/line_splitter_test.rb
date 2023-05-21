require 'test_helper'

class LineSplitterTest < BaseEngineTest

  def test_splitting_a_line
    str = "name type value\n"
    o = GlooLang::Persist::LineSplitter.new( str, 0 )
    n, t, v = o.split
    assert_equal 'name', n
    assert_equal 'type', t
    assert_equal 'value', v

    str = "name [type] one two three\n"
    o = GlooLang::Persist::LineSplitter.new( str, 0 )
    n, t, v = o.split
    assert_equal 'name', n
    assert_equal 'type', t
    assert_equal 'one two three', v

    str = 'my_string [str] : xyz'
    o = GlooLang::Persist::LineSplitter.new( str, 0 )
    n, t, v = o.split
    assert_equal 'my_string', n
    assert_equal 'str', t
    assert_equal 'xyz', v
  end


end
