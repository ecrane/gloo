require 'test_helper'

class ModeTest < BaseTest

  def test_mode
    mode = GlooLang::App::Mode::EMBED
    assert mode
  end

  def test_default_mode
    default = GlooLang::App::Mode.default_mode
    assert default
    assert_equal GlooLang::App::Mode::EMBED, default
  end

end
