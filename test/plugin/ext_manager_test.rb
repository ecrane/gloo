require 'test_helper'

class ExtManagerTest < BaseEngineTest

  def test_empty_ext_list
    o = @engine.ext_manager.loaded_extensions
    assert o
    assert_equal  0, o.count
  end

  def test_loading_extension
    @engine.parser.run 'load ext t'

    o = @engine.ext_manager.loaded_extensions
    assert o
    assert_equal  1, o.count

    @engine.parser.run 't'
    assert_equal 't', @engine.heap.it.value
  end

end
