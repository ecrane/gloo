require 'test_helper'

class PlatformTest < BaseEngineTest

  def test_platform_in_default_test_engine
    assert @engine
    assert @engine.platform
  end

  def test_page_falls_back_to_puts_when_not_a_tty
    # Test output isn't a real tty, so page should behave like show/puts
    # instead of trying to launch an interactive pager.
    out, _err = capture_io do
      @engine.platform.page 'hello world'
    end
    assert_match 'hello world', out
  end

end
