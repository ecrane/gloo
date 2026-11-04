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

  def test_save_to_a_computed_path
    @engine.parser.run 'create fresh as can'
    @engine.parser.run 'create fresh.s as string : hi'
    @engine.parser.run "create d as string : #{@tmp_dir}"

    @engine.parser.run "save fresh to ( d '/computed' )"
    refute @engine.error?
    path = File.join( @tmp_dir, 'computed.gloo' )
    assert File.exist?( path )
    assert_includes File.read( path ), 's [string] : hi'
  end

  def test_save_to_a_path_held_in_an_object
    @engine.parser.run 'create fresh as can'
    @engine.parser.run "create p as string : #{@tmp_dir}/held"

    @engine.parser.run 'save fresh to ( p )'
    refute @engine.error?
    assert File.exist?( File.join( @tmp_dir, 'held.gloo' ) )
  end

  def test_save_to_a_computed_path_from_an_unknown_object_is_an_error
    @engine.parser.run 'create fresh as can'
    @engine.parser.run 'save fresh to ( no_such_obj )'
    assert @engine.error?
    refute_equal Gloo::Verbs::Save::MISSING_PATH_ERR, @engine.heap.error.value
    assert_empty Dir.children( @tmp_dir )
  end

  def test_save_to_a_computed_path_that_is_blank
    @engine.parser.run 'create fresh as can'
    @engine.parser.run 'create p as string'
    @engine.parser.run 'save fresh to ( p )'
    assert @engine.error?
    assert_equal Gloo::Verbs::Save::MISSING_PATH_ERR, @engine.heap.error.value
  end

  def test_save_with_no_mapping_uses_a_default_path
    # Typed at the prompt: the working folder.
    Dir.chdir( File.realpath( @tmp_dir ) ) do
      @engine.parser.run 'create fresh_default as can'
      @engine.parser.run 'save fresh_default'
      refute @engine.error?
      assert File.exist?( File.join( Dir.pwd, 'fresh_default.gloo' ) )
    end
  end

  # -------------------------------------------------------------------
  #   Where a new file saved with a relative name goes
  # -------------------------------------------------------------------

  def test_a_script_saves_to_a_relative_name_next_to_its_file
    with_save_tree( 'save fresh to notes' ) do |near, project|
      @engine.parser.run "load #{near}/main"
      refute @engine.error?
      assert File.exist?( File.join( near, 'notes.gloo' ) )
      refute File.exist?( File.join( project, 'notes.gloo' ) )
    end
  end

  def test_a_script_saves_to_a_relative_path_next_to_its_file
    with_save_tree( 'save fresh to sub/notes' ) do |near, _project|
      FileUtils.mkdir_p( File.join( near, 'sub' ) )
      @engine.parser.run "load #{near}/main"
      refute @engine.error?
      assert File.exist?( File.join( near, 'sub', 'notes.gloo' ) )
    end
  end

  def test_a_script_saves_a_new_root_next_to_its_file
    with_save_tree( 'save fresh' ) do |near, project|
      @engine.parser.run "load #{near}/main"
      refute @engine.error?
      assert File.exist?( File.join( near, 'fresh.gloo' ) )
      refute File.exist?( File.join( project, 'fresh.gloo' ) )
    end
  end

  def test_telling_a_new_root_to_save_from_a_script_goes_next_to_its_file
    with_save_tree( 'tell fresh to save' ) do |near, _project|
      @engine.parser.run "load #{near}/main"
      refute @engine.error?
      assert File.exist?( File.join( near, 'fresh.gloo' ) )
    end
  end

  def test_in_app_mode_a_relative_save_goes_in_the_app_folder
    with_save_tree( 'save fresh to notes' ) do |near, project|
      @engine.define_singleton_method( :mode ) { Gloo::App::Mode::APP }
      @engine.parser.run "load #{near}/main"
      refute @engine.error?
      assert File.exist?( File.join( project, 'notes.gloo' ) )
      refute File.exist?( File.join( near, 'notes.gloo' ) )
    end
  end

  def test_a_script_not_from_a_file_saves_in_the_projects_folder
    with_save_tree( 'show 1' ) do |_near, project|
      Dir.chdir( File.dirname( project ) ) do
        @engine.parser.run 'create fresh as can'
        @engine.parser.run 'create s as script'
        @engine.parser.run "put 'save fresh to notes' into s"
        @engine.parser.run 'run s'
        refute @engine.error?
        assert File.exist?( File.join( project, 'notes.gloo' ) )
        refute File.exist?( File.join( Dir.pwd, 'notes.gloo' ) )
      end
    end
  end

  def test_a_typed_save_to_a_relative_name_goes_in_the_working_folder
    with_save_tree( 'show 1' ) do |near, project|
      Dir.chdir( near ) do
        @engine.parser.run 'create fresh as can'
        @engine.parser.run 'save fresh to notes'
        refute @engine.error?
        assert File.exist?( File.join( near, 'notes.gloo' ) )
        refute File.exist?( File.join( project, 'notes.gloo' ) )
      end
    end
  end

  def test_a_loaded_object_still_saves_to_its_own_file
    with_save_tree( "put 'changed' into other.s\n    save other" ) do |near, project|
      elsewhere = File.join( File.dirname( project ), 'elsewhere' )
      FileUtils.mkdir_p( elsewhere )
      File.write( File.join( elsewhere, 'other.gloo' ), "other [can] :\n  s [string] : hi\n" )
      @engine.parser.run "load #{elsewhere}/other"
      @engine.parser.run "load #{near}/main"
      refute @engine.error?
      assert_includes File.read( File.join( elsewhere, 'other.gloo' ) ), 's [string] : changed'
      refute File.exist?( File.join( near, 'other.gloo' ) )
    end
  end

  def test_save_to_a_tilde_path_goes_in_the_home_folder
    home = File.realpath( @tmp_dir )
    with_home( home ) do
      @engine.parser.run 'create fresh as can'
      @engine.parser.run 'save fresh to ~/tilde_notes'
      refute @engine.error?
      assert File.exist?( File.join( home, 'tilde_notes.gloo' ) )
      refute File.exist?( File.join( @engine.settings.project_path, '~' ) )
    end
  end

  # -------------------------------------------------------------------
  #   save {obj} to {path} -- extraction
  # -------------------------------------------------------------------

  def load_extraction_fixture( content )
    pn = File.join( @tmp_dir, 'src.gloo' )
    File.write( pn, content )
    @engine.persist_man.load pn
  end

  def test_extracting_a_leaf_moves_it_out_of_the_old_file
    load_extraction_fixture( <<~GLOO )
      app [can] :
        core [can] :
          # the theme setting
          settings [can] :
            theme [string] : dark
          other [string] : hi
    GLOO
    path = File.join( @tmp_dir, 'extracted' )

    @engine.parser.run "save app.core.settings to #{path}"
    refute @engine.error?

    extracted = File.read( "#{path}.gloo" )
    assert_includes extracted, 'app.core.settings [can] :'
    assert_includes extracted, "  theme [string] : dark"
    assert_includes extracted, '# the theme setting'

    src = File.read( File.join( @tmp_dir, 'src.gloo' ) )
    refute_includes src, 'settings'
    assert_includes src, 'other [string] : hi'
  end

  def test_extraction_registers_the_target_so_later_edits_save_there
    load_extraction_fixture( <<~GLOO )
      app [can] :
        core [can] :
          settings [can] :
            theme [string] : dark
    GLOO
    path = File.join( @tmp_dir, 'extracted' )
    @engine.parser.run "save app.core.settings to #{path}"

    @engine.parser.run "put 'light' into app.core.settings.theme"
    @engine.parser.run 'save'
    refute @engine.error?

    assert_includes File.read( "#{path}.gloo" ), 'theme [string] : light'
  end

  def test_a_later_bare_save_does_not_resurrect_the_extracted_object
    load_extraction_fixture( <<~GLOO )
      app [can] :
        core [can] :
          settings [can] :
            theme [string] : dark
          other [string] : hi
    GLOO
    path = File.join( @tmp_dir, 'extracted' )
    @engine.parser.run "save app.core.settings to #{path}"

    @engine.parser.run 'save'
    refute @engine.error?
    refute_includes File.read( File.join( @tmp_dir, 'src.gloo' ) ), 'settings'
  end

  def test_extracting_a_whole_root_shared_with_another_root
    load_extraction_fixture( <<~GLOO )
      foo [can] :
        x [string] : one
      bar [can] :
        y [string] : two
    GLOO
    path = File.join( @tmp_dir, 'extracted' )

    @engine.parser.run "save bar to #{path}"
    refute @engine.error?

    src = File.read( File.join( @tmp_dir, 'src.gloo' ) )
    assert_includes src, 'foo [can] :'
    refute_includes src, 'bar'
    assert_includes File.read( "#{path}.gloo" ), 'bar [can] :'
  end

  def test_extracting_a_never_loaded_nested_object
    load_extraction_fixture( <<~GLOO )
      app [can] :
        core [can] :
          other [string] : hi
    GLOO
    @engine.parser.run 'create app.core.new_thing as string : brand_new'
    path = File.join( @tmp_dir, 'extracted' )

    @engine.parser.run "save app.core.new_thing to #{path}"
    refute @engine.error?
    assert_includes File.read( "#{path}.gloo" ), 'app.core.new_thing [string] : brand_new'
    assert_includes File.read( File.join( @tmp_dir, 'src.gloo' ) ), 'other [string] : hi'
  end

  def test_extraction_refuses_a_subtree_spanning_multiple_files
    load_extraction_fixture( <<~GLOO )
      app [can] :
        core [can] :
          settings [can] :
            theme [string] : dark
    GLOO
    other_pn = File.join( @tmp_dir, 'other.gloo' )
    File.write( other_pn, <<~GLOO )
      app [can] :
        core [can] :
          settings [can] :
            volume [string] : loud
    GLOO
    @engine.persist_man.load other_pn

    path = File.join( @tmp_dir, 'extracted' )
    @engine.parser.run "save app.core.settings to #{path}"

    assert @engine.error?
    refute File.exist?( "#{path}.gloo" )
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

  def test_save_it_is_an_error
    @engine.parser.run "eval 'abc'"
    @engine.parser.run 'save it'
    assert @engine.error?
    assert_includes @engine.heap.error.value, "it isn't an object and can't be saved;"
    assert_equal 'abc', @engine.heap.it.value
  end

  def test_save_it_to_a_path_is_an_error
    @engine.parser.run "eval 'abc'"
    @engine.parser.run 'save it to /tmp/gloo_it_save.gloo'
    assert @engine.error?
    refute File.exist?( '/tmp/gloo_it_save.gloo' )
    assert_equal 'abc', @engine.heap.it.value
  end

  private

  #
  # Yield two scratch folders, near and project. near has main.gloo,
  # whose on_load creates a new root, fresh, and then runs the given
  # line(s). The projects folder is set to project.
  #
  def with_save_tree( line )
    root = File.realpath( Dir.mktmpdir )
    near = File.join( root, 'near' )
    project = File.join( root, 'project' )
    FileUtils.mkdir_p( [ near, project ] )
    File.write( File.join( near, 'main.gloo' ),
                "main [can] :\n  on_load [script] :\n    create fresh as can\n    #{line}\n" )
    @engine.settings.override_project_path( project )
    yield near, project
  ensure
    FileUtils.remove_entry root if root
  end

  #
  # Run the block with HOME set to the given folder, so ~ means it.
  #
  def with_home( folder )
    old = ENV.fetch( 'HOME', nil )
    ENV['HOME'] = folder
    yield
  ensure
    ENV['HOME'] = old
  end

end
