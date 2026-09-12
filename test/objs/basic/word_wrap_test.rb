require 'test_helper'

class WordWrapTest < BaseEngineTest

  def test_wraps_at_the_given_width
    text = 'one two three four five six seven eight'
    wrapped = Gloo::Objs::WordWrap.wrap( text, 10 )

    wrapped.split( "\n" ).each do |line|
      assert line.length <= 10
    end
    # Re-joining the wrapped words (undoing the wrap) should recover
    # the original text -- no words dropped or duplicated.
    assert_equal text, wrapped.split( "\n" ).join( ' ' )
  end

  def test_never_breaks_mid_word
    text = 'a b http://example.com/a-really-long-url-segment c d'
    wrapped = Gloo::Objs::WordWrap.wrap( text, 10 )

    assert_includes wrapped.split( "\n" ), 'http://example.com/a-really-long-url-segment'
  end

  def test_short_text_is_not_wrapped
    text = 'short'
    assert_equal text, Gloo::Objs::WordWrap.wrap( text, 80 )
  end

  def test_preserves_existing_line_breaks
    text = "alpha beta\n\ngamma delta epsilon zeta eta theta"
    wrapped = Gloo::Objs::WordWrap.wrap( text, 10 )

    lines = wrapped.split( "\n" )
    assert_equal 'alpha beta', lines[ 0 ]
    assert_equal '', lines[ 1 ]
    lines[ 2.. ].each do |line|
      assert line.length <= 10
    end
  end

  def test_zero_or_negative_width_returns_text_unchanged
    text = 'one two three'
    assert_equal text, Gloo::Objs::WordWrap.wrap( text, 0 )
    assert_equal text, Gloo::Objs::WordWrap.wrap( text, -5 )
  end

  def test_blank_text_returns_blank
    assert_equal '', Gloo::Objs::WordWrap.wrap( '', 10 )
  end

end
