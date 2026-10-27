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

  private

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
