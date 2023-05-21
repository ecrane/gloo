require 'test_helper'

class FormatTest < BaseTest

  def test_formatting_number
    num = 1000
    formatted = Gloo::Utils::Format.number( num )
    assert_equal '1,000', formatted

    num = 100
    formatted = Gloo::Utils::Format.number( num )
    assert_equal '100', formatted

    num = 0
    formatted = Gloo::Utils::Format.number( num )
    assert_equal '0', formatted
  end

end
