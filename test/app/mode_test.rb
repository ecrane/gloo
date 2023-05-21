require 'test_helper'

class ModeTest < BaseTest

  def test_mode
    mode = Gloo::App::Mode::EMBED
    assert mode
  end

  def test_default_mode
    default = Gloo::App::Mode.default_mode
    assert default
    assert_equal Gloo::App::Mode::EMBED, default
  end

end
