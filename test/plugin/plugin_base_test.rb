require 'test_helper'

class PluginBaseTest < BaseEngineTest

  def test_register_needs_subclass
    b = Gloo::Plugin::Base.new
    assert_raises( NotImplementedError ) do
      b.register( nil )
    end
  end

end
