require 'test_helper'

class LibManagerTest < BaseEngineTest

  def test_empty_lib_list
    o = @engine.lib_manager.loaded_libraries
    assert o
    assert_equal  0, o.count
  end

  def test_loading_library
    @engine.parser.run 'load lib test'

    o = @engine.lib_manager.loaded_libraries
    assert o
    assert_equal  1, o.count

    assert @dic.verb?( 'assert' )
  end

  def test_pinned
    refute @engine.lib_manager.pinned?( 'test' )
    @engine.lib_manager.load_lib 'test', pinned: true
    assert @engine.lib_manager.pinned?( 'test' )
  end

  def test_unload_lib_returns_whether_it_was_unloaded
    @engine.lib_manager.load_lib 'test', pinned: true
    refute @engine.lib_manager.unload_lib( 'test' )
    assert @engine.lib_manager.unload_lib( 'nosuchlib' )
  end

end
