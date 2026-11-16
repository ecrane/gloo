require 'test_helper'

#
# Engine#reset_session and #reset_state: what each keeps of the
# libraries and extensions that were loaded.
#
class EngineResetTest < BaseEngineTest

  def test_reset_session_unloads_libraries_and_extensions
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load lib md'
      @engine.parser.run 'load ext t'
      @engine.parser.run 'create m as markdown'

      @engine.reset_session

      # The heap is emptied first, so the markdown object didn't stop it.
      assert_equal 0, @engine.heap.root.child_count
      refute @engine.lib_manager.loaded_libraries.key?( 'md' )
      refute @engine.ext_manager.loaded_extensions.key?( 't' )
      refute @dic.obj?( 'markdown' )
      refute @dic.verb?( 't' )
      refute @engine.error?
    end
  end

  def test_reset_session_keeps_pinned_libraries
    keeping_the_dictionary_as_it_was do
      @engine.lib_manager.load_lib 'test', pinned: true
      @engine.reset_session

      assert @engine.lib_manager.loaded_libraries.key?( 'test' )
      assert @dic.verb?( 'assert' )
    end
  end

  def test_load_lib_after_reset_session
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load lib md'
      @engine.reset_session
      @engine.parser.run 'load lib md'

      assert @engine.lib_manager.loaded_libraries.key?( 'md' )
      assert @dic.obj?( 'markdown' )
    end
  end

  def test_reset_state_keeps_libraries
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load lib md'
      @engine.parser.run 'load ext t'
      @engine.reset_state

      assert @engine.lib_manager.loaded_libraries.key?( 'md' )
      assert @engine.ext_manager.loaded_extensions.key?( 't' )
      assert @dic.obj?( 'markdown' )
    end
  end

end
