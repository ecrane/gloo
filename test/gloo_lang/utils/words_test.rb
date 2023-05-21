require 'test_helper'

class WordsTest < BaseTest

  def test_active_support
    o = GlooLang::Utils::Words.pluralize( 'Tomato' )
    assert_equal 'Tomatoes', o
  end

end
