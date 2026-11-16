require 'test_helper'

class UnloadTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'unload', Gloo::Verbs::Unload.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'u!', Gloo::Verbs::Unload.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Unload.doc_data
    assert_equal Gloo::Verbs::Unload.keyword, data[:name]
    assert_equal Gloo::Verbs::Unload.keyword_shortcut, data[:shortcut]
  end

  def test_unloading_all_files
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'unload'

    assert_equal 0, @engine.heap.root.child_count
  end

  def test_unloading_a_file
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'tell test to unload'

    assert_equal 0, @engine.heap.root.child_count
  end

  def test_unload_with_an_object_is_an_error_and_unloads_nothing
    @engine.parser.run 'load test'
    @engine.parser.run 'unload test'

    assert @engine.error?
    assert_equal Gloo::Verbs::Unload::WRONG_ARGS_ERR, @engine.heap.error.value
    assert_includes @engine.heap.error.value, 'tell x to unload'
    assert_equal 1, @engine.heap.root.child_count
  end

  def test_plain_unload_has_no_error
    @engine.parser.run 'load test'
    @engine.parser.run 'unload'
    refute @engine.error?
  end

  def test_unload_lib_removes_its_types
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load lib md'
      assert @dic.obj?( 'markdown' )

      @engine.parser.run 'unload lib md'
      refute @engine.error?
      refute @dic.obj?( 'markdown' )
      refute @engine.lib_manager.loaded_libraries.key?( 'md' )
    end
  end

  def test_load_lib_after_unload_brings_it_back
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load lib md'
      @engine.parser.run 'unload lib md'
      @engine.parser.run 'load lib md'
      assert @dic.obj?( 'markdown' )
      assert @engine.lib_manager.loaded_libraries.key?( 'md' )
    end
  end

  def test_unload_lib_with_a_computed_name
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load lib md'
      @engine.parser.run 'create n as string : md'
      @engine.parser.run 'unload lib ( n )'
      refute @dic.obj?( 'markdown' )
    end
  end

  def test_unload_lib_with_its_objects_on_the_heap_is_an_error
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load lib md'
      @engine.parser.run 'create m as markdown'
      @engine.parser.run 'create c as can'
      @engine.parser.run 'create c.inner as markdown'
      @engine.parser.run 'unload lib md'

      assert_equal Gloo::Core::Error::RUNTIME, @engine.heap.error.kind
      assert_equal format( Gloo::Plugin::LibManager::IN_USE_ERR, 'md', 'm, c.inner' ),
                   @engine.heap.error.value
      assert_equal false, @engine.heap.it.value
      # Nothing was unloaded.
      assert @dic.obj?( 'markdown' )
      assert @engine.lib_manager.loaded_libraries.key?( 'md' )
    end
  end

  def test_unload_lib_that_is_not_loaded_does_nothing
    @engine.parser.run 'unload lib nosuchlib'
    refute @engine.error?
  end

  def test_unload_a_pinned_lib_is_an_error
    keeping_the_dictionary_as_it_was do
      @engine.lib_manager.load_lib 'test', pinned: true
      @engine.parser.run 'unload lib test'

      assert_equal format( Gloo::Plugin::LibManager::PINNED_ERR, 'test' ), @engine.heap.error.value
      assert @dic.verb?( 'assert' )
      assert @engine.lib_manager.loaded_libraries.key?( 'test' )
    end
  end

  def test_unload_ext_removes_its_verbs
    keeping_the_dictionary_as_it_was do
      @engine.parser.run 'load ext t'
      assert @dic.verb?( 't' )

      @engine.parser.run 'unload ext t'
      refute @engine.error?
      refute @dic.verb?( 't' )

      @engine.parser.run 'load ext t'
      assert @dic.verb?( 't' )
    end
  end

  def test_unload_lib_without_a_name_is_a_syntax_error
    @engine.parser.run 'unload lib'
    assert_equal Gloo::Verbs::Unload::MISSING_NAME_ERR, @engine.heap.error.value
    assert_equal Gloo::Core::Error::SYNTAX, @engine.heap.error.kind
    assert_equal false, @engine.heap.it.value
  end

  def test_unload_with_other_words_is_an_error
    [ 'unload file x', 'unload lib md extra' ].each do |cmd|
      @engine.heap.error.clear
      @engine.parser.run cmd
      assert_equal Gloo::Verbs::Unload::WRONG_ARGS_ERR, @engine.heap.error.value, cmd
    end
  end

end
