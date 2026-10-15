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

end
