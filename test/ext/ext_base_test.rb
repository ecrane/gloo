require 'test_helper'

class ExtBaseTest < BaseEngineTest

  def test_register_needs_subclass
    b = Gloo::Ext::Base.new
    assert_raises( NotImplementedError ) do
      b.register( nil )
    end
  end

end
