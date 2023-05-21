require 'test_helper'

class PlatformTest < BaseEngineTest

  def test_platform_in_default_test_engine
    assert @engine
    assert @engine.platform
  end

  def test_platform_prompt
    o = @engine.platform
    assert o
    cmd = o.prompt_cmd
    assert_equal '', cmd
  end

end
