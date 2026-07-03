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

  def test_all_mode_constants_defined
    assert Gloo::App::Mode::EMBED
    assert Gloo::App::Mode::APP
    assert Gloo::App::Mode::CLI
    assert Gloo::App::Mode::SCRIPT
    assert Gloo::App::Mode::VERSION
    assert Gloo::App::Mode::HELP
    assert Gloo::App::Mode::TEST
  end

end
