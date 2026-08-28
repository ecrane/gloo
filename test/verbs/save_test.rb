require 'test_helper'

class SaveTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'save', Gloo::Verbs::Save.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'sv', Gloo::Verbs::Save.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Save.doc_data
    assert_equal Gloo::Verbs::Save.keyword, data[:name]
    assert_equal Gloo::Verbs::Save.keyword_shortcut, data[:shortcut]
  end

  # These load the existing test.gloo fixture, write it back, and
  # restore it afterward so the checked-in copy never changes.

  def fixture_path
    File.join( default_user_root, 'projects', 'test.gloo' )
  end

  def test_save_all_completes_without_error
    original = File.read( fixture_path )
    @engine.parser.run 'load test'
    @engine.parser.run 'save'
    refute @engine.error?
  ensure
    File.write( fixture_path, original ) if original
  end

  def test_save_persists_a_change_to_disk
    original = File.read( fixture_path )

    @engine.parser.run 'load test'
    @engine.parser.run "put 'changed' into test.msg"
    @engine.parser.run 'save test'
    refute @engine.error?

    # a fresh engine reads the new value back from the file
    other = Gloo::App::Engine.new( default_context )
    other.log.quiet = true
    other.start
    other.parser.run 'load test'
    assert_equal 'changed', other.heap.root.find_child( 'test' ).find_child( 'msg' ).value
    other.stop_running
  ensure
    File.write( fixture_path, original ) if original
  end

end
