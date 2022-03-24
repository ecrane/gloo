require 'test_helper'

class PlatformTest < BaseEngineTest

  def test_platform_in_default_test_engine
    assert @engine
    assert @engine.platform
  end

end
