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

  def test_unloading_extension
    @engine.parser.run 'load ext t'
    assert @engine.ext_manager.unload_ext( 't' )
    assert_equal 0, @engine.ext_manager.loaded_extensions.count
    refute @dic.verb?( 't' )
  end

  def test_unloading_an_extension_that_is_not_loaded
    assert @engine.ext_manager.unload_ext( 'nosuchext' )
    refute @engine.error?
  end

end
