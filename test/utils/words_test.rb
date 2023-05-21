require 'test_helper'

class WordsTest < BaseTest

  def test_active_support
    o = Gloo::Utils::Words.pluralize( 'Tomato' )
    assert_equal 'Tomatoes', o
  end

end
