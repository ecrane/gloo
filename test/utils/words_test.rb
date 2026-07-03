require 'test_helper'

class WordsTest < BaseTest

  def test_active_support
    o = Gloo::Utils::Words.pluralize( 'Tomato' )
    assert_equal 'Tomatoes', o
  end

  def test_lowercase_word
    o = Gloo::Utils::Words.pluralize( 'apple' )
    assert_equal 'apples', o
  end

  def test_irregular_plural
    o = Gloo::Utils::Words.pluralize( 'child' )
    assert_equal 'children', o
  end

  def test_already_plural
    o = Gloo::Utils::Words.pluralize( 'apples' )
    assert_equal 'apples', o
  end

end
