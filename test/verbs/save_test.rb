require 'test_helper'
require 'tmpdir'

class SaveTest < BaseEngineTest

  def setup
    super
    @tmp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry @tmp_dir
    super
  end

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

  def test_save_to_a_new_path_creates_the_file_and_registers_the_mapping
    @engine.parser.run 'create fresh as can'
    @engine.parser.run "create fresh.s as string : hi"
    path = File.join( @tmp_dir, 'fresh' )

    @engine.parser.run "save fresh to #{path}"
    refute @engine.error?
    assert File.exist?( "#{path}.gloo" )
    assert_includes File.read( "#{path}.gloo" ), 's [string] : hi'

    # registered -- a later bare save (for that object, or for all
    # open files) includes it without another 'to'.
    @engine.parser.run "put 'changed' into fresh.s"
    @engine.parser.run 'save fresh'
    refute @engine.error?
    assert_includes File.read( "#{path}.gloo" ), 's [string] : changed'
  end

  def test_save_to_refuses_to_overwrite_a_file_it_does_not_own
    path = File.join( @tmp_dir, 'taken.gloo' )
    File.write( path, "not a gloo file we loaded\n" )

    @engine.parser.run 'create fresh as can'
    @engine.parser.run "save fresh to #{@tmp_dir}/taken"

    assert @engine.error?
    assert_equal "not a gloo file we loaded\n", File.read( path )
  end

  def test_save_to_with_no_path_is_an_error
    @engine.parser.run 'create fresh as can'
    @engine.parser.run 'save fresh to'
    assert @engine.error?
  end

  def test_save_with_no_mapping_uses_a_default_path
    default_pn = File.join( @engine.settings.project_path, 'fresh_default.gloo' )
    refute File.exist?( default_pn ), 'test setup: nothing should be there yet'

    @engine.parser.run 'create fresh_default as can'
    @engine.parser.run 'save fresh_default'
    refute @engine.error?
    assert File.exist?( default_pn )
  ensure
    File.delete( default_pn ) if default_pn && File.exist?( default_pn )
  end

  def test_saving_an_unresolvable_object_is_an_error
    @engine.parser.run 'save no.such.object'
    assert @engine.error?
  end

  def test_telling_an_object_to_save
    original = File.read( fixture_path )

    @engine.parser.run 'load test'
    @engine.parser.run "put 'told to save' into test.msg"
    @engine.parser.run 'tell test to save'
    refute @engine.error?

    other = Gloo::App::Engine.new( default_context )
    other.log.quiet = true
    other.start
    other.parser.run 'load test'
    assert_equal 'told to save', other.heap.root.find_child( 'test' ).find_child( 'msg' ).value
    other.stop_running
  ensure
    File.write( fixture_path, original ) if original
  end

end
