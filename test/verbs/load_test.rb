require 'test_helper'
require 'tmpdir'

class LoadTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'load', Gloo::Verbs::Load.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'ld', Gloo::Verbs::Load.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Load.doc_data
    assert_equal Gloo::Verbs::Load.keyword, data[:name]
    assert_equal Gloo::Verbs::Load.keyword_shortcut, data[:shortcut]
  end

  def test_file_load
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'load test'
    i.run
    assert_equal 1, @engine.heap.root.child_count
  end

  def test_file_load_with_opt
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'load file test'
    i.run
    assert_equal 1, @engine.heap.root.child_count
  end

  def test_file_load_multiline_script
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'load script'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 5, @engine.heap.it.value
  end

  def test_loading_a_comments_only_file_is_not_an_error
    dir = Dir.mktmpdir
    File.write( File.join( dir, 'empty.gloo' ), "# a comment\n" )
    @engine.settings.override_project_path( "#{dir}/" )

    warnings = capture_warnings { @engine.parser.run 'load empty' }
    refute @engine.error?
    assert_equal 0, @engine.heap.root.child_count
    assert_equal 1, warnings.size
  ensure
    FileUtils.remove_entry dir if dir
  end

  def test_load_without_expression
    @engine.parser.run 'load'
    assert @engine.error?
    assert_equal Gloo::Verbs::Load::WRONG_NUM_ARGS_ERR, @engine.heap.error.value
  end

  # ---------------------------------------------------------------------
  #    Computed path: load ( expr )
  # ---------------------------------------------------------------------

  def test_load_a_computed_path
    with_fixture_dir do |dir|
      @engine.parser.run "create d as string : #{dir}"
      @engine.parser.run "load ( d + '/alpha.gloo' )"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_a_computed_path_with_implicit_concat
    with_fixture_dir do |dir|
      @engine.parser.run "create d as string : #{dir}"
      @engine.parser.run "load ( d '/alpha.gloo' )"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_a_path_held_in_an_object
    with_fixture_dir do |dir|
      @engine.parser.run "create p as string : #{dir}/alpha.gloo"
      @engine.parser.run 'load ( p )'
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_a_computed_path_without_spaces_in_the_parens
    with_fixture_dir do |dir|
      @engine.parser.run "create p as string : #{dir}/alpha.gloo"
      @engine.parser.run 'load (p)'
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_file_with_a_computed_path
    with_fixture_dir do |dir|
      @engine.parser.run "create d as string : #{dir}"
      @engine.parser.run "load file ( d '/alpha.gloo' )"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_a_computed_relative_path_adds_the_gloo_extension
    with_fixture_dir do |dir|
      @engine.settings.override_project_path( "#{dir}/" )
      @engine.parser.run "load ( 'alp' 'ha' )"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_a_computed_relative_wildcard_path
    # Relative, like real uses (load common/app/*); an absolute
    # wildcard has its own bug, see the Backlog.
    with_fixture_dir do |dir|
      @engine.settings.override_project_path( "#{File.dirname( dir )}/" )
      @engine.parser.run "create d as string : #{File.basename( dir )}"
      @engine.parser.run "load ( d '/*' )"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
      assert @engine.heap.root.find_child( 'beta' )
    end
  end

  def test_load_a_computed_path_to_a_missing_file_names_that_path
    with_fixture_dir do |dir|
      @engine.parser.run "create d as string : #{dir}"
      @engine.parser.run "load ( d '/missing.gloo' )"
      assert @engine.error?
      assert_includes @engine.heap.error.value, "#{dir}/missing.gloo"
    end
  end

  def test_load_a_computed_path_from_an_unknown_object_is_an_error
    count = @engine.heap.root.child_count
    @engine.parser.run 'load ( no_such_obj )'
    assert @engine.error?
    refute_equal Gloo::Verbs::Load::WRONG_NUM_ARGS_ERR, @engine.heap.error.value
    assert_equal count, @engine.heap.root.child_count
  end

  def test_load_a_computed_path_that_is_blank
    @engine.parser.run 'create p as string'
    @engine.parser.run 'load ( p )'
    assert @engine.error?
    assert_equal Gloo::Verbs::Load::MISSING_EXPR_ERR, @engine.heap.error.value
  end

  # ---------------------------------------------------------------------
  #    A wildcard in an absolute path
  # ---------------------------------------------------------------------

  def test_load_an_absolute_wildcard_path
    with_fixture_dir do |dir|
      @engine.parser.run "load #{dir}/*"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
      assert @engine.heap.root.find_child( 'beta' )
    end
  end

  def test_load_a_computed_absolute_wildcard_path
    with_fixture_dir do |dir|
      @engine.parser.run "create d as string : #{dir}"
      @engine.parser.run "load ( d '/*' )"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
      assert @engine.heap.root.find_child( 'beta' )
    end
  end

  def test_load_an_absolute_wildcard_in_a_missing_folder_is_an_error
    with_fixture_dir do |dir|
      @engine.parser.run "load #{dir}/nope/*"
      assert @engine.error?
      assert_equal Gloo::Core::NotFound.file( "#{dir}/nope/*" ), @engine.heap.error.value
    end
  end

  # ---------------------------------------------------------------------
  #    The .gloo extension is optional, for any kind of path
  # ---------------------------------------------------------------------

  def test_load_a_full_path_without_the_extension
    with_fixture_dir do |dir|
      @engine.parser.run "load #{dir}/alpha"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_a_computed_full_path_without_the_extension
    with_fixture_dir do |dir|
      @engine.parser.run "create d as string : #{dir}"
      @engine.parser.run "load ( d '/alpha' )"
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  def test_load_a_project_name_with_the_extension
    with_fixture_dir do |dir|
      @engine.settings.override_project_path( "#{dir}/" )
      @engine.parser.run 'load alpha.gloo'
      refute @engine.error?
      assert @engine.heap.root.find_child( 'alpha' )
    end
  end

  # A library or extension stays registered for the rest of the test
  # run (see the reset-state Backlog project), so these check the name
  # that reaches the manager rather than loading it.

  def test_load_lib_with_a_computed_name
    names = []
    @engine.lib_manager.define_singleton_method( :load_lib ) { |name| names << name }
    @engine.parser.run "create n as string : 'm'"
    @engine.parser.run "load lib ( n 'd' )"
    refute @engine.error?
    assert_equal [ 'md' ], names
  end

  def test_load_ext_with_a_computed_name
    names = []
    @engine.ext_manager.define_singleton_method( :load_ext ) { |name| names << name }
    @engine.parser.run "create n as string : 'al'"
    @engine.parser.run "load ext ( n 'ert' )"
    refute @engine.error?
    assert_equal [ 'alert' ], names
  end

  def test_a_literal_file_name_is_not_evaluated
    # 'test' is both a fixture file and, once loaded, an object; a bare
    # name still means the file, so loading it again works the same way.
    @engine.parser.run 'load test'
    @engine.parser.run 'load test'
    refute @engine.error?
  end

  # ---------------------------------------------------------------------
  #    Where a relative load looks
  # ---------------------------------------------------------------------

  def test_a_script_loads_next_to_its_file_first
    with_load_tree do |near, _project|
      @engine.parser.run "load #{near}/main"
      assert_equal 'near', x_value
    end
  end

  def test_a_script_falls_back_to_the_projects_folder
    with_load_tree do |near, _project|
      FileUtils.rm_r( File.join( near, 'lib' ) )
      @engine.parser.run "load #{near}/main"
      assert_equal 'project', x_value
    end
  end

  def test_a_script_does_not_look_in_the_working_folder
    with_load_tree do |near, project|
      FileUtils.rm_r( File.join( near, 'lib' ) )
      FileUtils.rm_r( File.join( project, 'lib' ) )
      elsewhere = File.join( File.dirname( near ), 'elsewhere' )
      write_x( elsewhere, 'working' )
      Dir.chdir( elsewhere ) { @engine.parser.run "load #{near}/main" }
      assert_nil @engine.heap.root.find_child( 'x' )
    end
  end

  def test_in_app_mode_the_app_folder_comes_first
    with_load_tree do |near, _project|
      @engine.define_singleton_method( :mode ) { Gloo::App::Mode::APP }
      @engine.parser.run "load #{near}/main"
      assert_equal 'project', x_value
    end
  end

  def test_in_app_mode_a_script_falls_back_to_next_to_its_file
    with_load_tree do |near, project|
      FileUtils.rm_r( File.join( project, 'lib' ) )
      @engine.define_singleton_method( :mode ) { Gloo::App::Mode::APP }
      @engine.parser.run "load #{near}/main"
      assert_equal 'near', x_value
    end
  end

  def test_a_script_run_from_elsewhere_loads_next_to_its_own_file
    with_load_tree do |near, _project|
      File.write( File.join( near, 'tools.gloo' ), "tools [can] :\n  get_x [script] : load lib/x\n" )
      @engine.parser.run "load #{near}/tools"
      @engine.parser.run 'run tools.get_x'
      assert_equal 'near', x_value
    end
  end

  def test_a_script_not_from_a_file_skips_next_to_it
    with_load_tree do |near, _project|
      @engine.parser.run 'create get_x as script'
      @engine.parser.run "put 'load lib/x' into get_x"
      Dir.chdir( near ) { @engine.parser.run 'run get_x' }
      assert_equal 'project', x_value
    end
  end

  def test_a_typed_command_loads_from_the_working_folder_first
    with_load_tree do |near, _project|
      Dir.chdir( near ) { @engine.parser.run 'load lib/x' }
      assert_equal 'near', x_value
    end
  end

  def test_a_script_loads_a_folder_next_to_its_file
    with_load_tree( 'load lib/*' ) do |near, _project|
      @engine.parser.run "load #{near}/main"
      assert_equal 'near', x_value
    end
  end

  def test_a_script_loads_a_computed_name_next_to_its_file
    with_load_tree( "load ( 'lib/' 'x' )" ) do |near, _project|
      @engine.parser.run "load #{near}/main"
      assert_equal 'near', x_value
    end
  end

  def test_search_folders_for_a_script_start_next_to_its_file
    with_load_tree( 'show 1' ) do |near, project|
      @engine.parser.run "load #{near}/main"
      script = @engine.heap.root.find_child( 'main' ).find_child( 'on_load' )
      folders = with_running_script( script ) { @engine.persist_man.search_folders }
      assert_equal [ near, project, @engine.settings.user_root ], folders
    end
  end

  def test_search_folders_in_app_mode_start_with_the_app_folder
    with_load_tree( 'show 1' ) do |near, project|
      @engine.parser.run "load #{near}/main"
      @engine.define_singleton_method( :mode ) { Gloo::App::Mode::APP }
      script = @engine.heap.root.find_child( 'main' ).find_child( 'on_load' )
      folders = with_running_script( script ) { @engine.persist_man.search_folders }
      assert_equal [ project, near, @engine.settings.user_root ], folders
    end
  end

  def test_search_folders_for_a_typed_command_start_with_the_working_folder
    folders = @engine.persist_man.search_folders
    assert_equal [ Dir.pwd, @engine.settings.project_path, @engine.settings.user_root ], folders
  end

  private

  #
  # Yield two scratch folders, near and project, each with lib/x.gloo
  # declaring x.v as the folder's name. near also has main.gloo, whose
  # on_load runs the given line. The projects folder is set to project.
  #
  def with_load_tree( line = 'load lib/x' )
    root = File.realpath( Dir.mktmpdir )
    near = File.join( root, 'near' )
    project = File.join( root, 'project' )
    write_x( near, 'near' )
    write_x( project, 'project' )
    File.write( File.join( near, 'main.gloo' ), "main [can] :\n  on_load [script] : #{line}\n" )
    @engine.settings.override_project_path( project )
    yield near, project
  ensure
    FileUtils.remove_entry root if root
  end

  #
  # Write folder/lib/x.gloo, declaring x.v with the given value.
  #
  def write_x( folder, value )
    FileUtils.mkdir_p( File.join( folder, 'lib' ) )
    File.write( File.join( folder, 'lib', 'x.gloo' ), "x [can] :\n  v [string] : #{value}\n" )
  end

  #
  # The value of x.v, or nil if x wasn't loaded.
  #
  def x_value
    return @engine.heap.root.find_child( 'x' )&.find_child( 'v' )&.value
  end

  #
  # Run the block as if the given script object were running.
  #
  def with_running_script( obj )
    @engine.exec_env.push_script( Gloo::Exec::Script.new( @engine, obj ) )
    return yield
  ensure
    @engine.exec_env.pop_script
  end

  #
  # Yield a scratch folder holding alpha.gloo and beta.gloo, each with
  # one root container named after the file.
  #
  def with_fixture_dir
    dir = Dir.mktmpdir
    File.write( File.join( dir, 'alpha.gloo' ), "alpha [can] :\n  s [string] : a\n" )
    File.write( File.join( dir, 'beta.gloo' ), "beta [can] :\n  s [string] : b\n" )
    yield dir
  ensure
    FileUtils.remove_entry dir if dir
  end

end
