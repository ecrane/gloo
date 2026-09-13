require 'test_helper'
require 'tmpdir'

class SubtreeExtractorTest < BaseEngineTest

  def setup
    super
    @tmp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry @tmp_dir
    super
  end

  #
  # Write content to a scratch file and load it, returning the
  # resulting FileStorage.
  #
  def load_fixture( name, content )
    pn = File.join( @tmp_dir, "#{name}.gloo" )
    File.write( pn, content )
    fs = Gloo::Persist::FileStorage.new( @engine, pn )
    fs.load
    return fs
  end

  def extractor
    return Gloo::Persist::SubtreeExtractor.new( @engine )
  end

  # -------------------------------------------------------------------
  #   The common case: obj owned by exactly one file
  # -------------------------------------------------------------------

  def test_extracts_a_leaf_owned_by_one_file
    fs = load_fixture( 'app', <<~GLOO )
      app [can] :
        core [can] :
          # the theme setting
          settings [can] :
            theme [string] : dark
          other [string] : hi
    GLOO
    settings = fs.obj.find_child( 'core' ).find_child( 'settings' )

    node, source_fs = extractor.extract( settings, [ fs ] )

    refute @engine.error?
    assert_same fs, source_fs
    assert_equal 'app.core.settings', node.name
    assert_equal '', node.raw_indent
    assert_equal '# the theme setting', node.leading_doc

    # removed from the old file's SourceDoc -- 'settings' node is gone,
    # 'other' is untouched
    core_node = fs.source_doc.children.first.children.first
    assert_equal [ 'other' ], core_node.children.map( &:name )
  end

  def test_reindents_descendants_and_their_leading_doc
    fs = load_fixture( 'app', <<~GLOO )
      app [can] :
        core [can] :
          settings [can] :
            # the theme
            theme [string] : dark
    GLOO
    settings = fs.obj.find_child( 'core' ).find_child( 'settings' )

    node, = extractor.extract( settings, [ fs ] )

    theme_node = node.children.first
    assert_equal 'theme', theme_node.name
    assert_equal "\t", theme_node.raw_indent
    assert_equal "\t# the theme", theme_node.leading_doc
  end

  def test_drops_the_extracted_root_from_the_source_files_roots
    fs = load_fixture( 'misc', <<~GLOO )
      foo [can] :
        x [string] : one
      bar [can] :
        y [string] : two
    GLOO
    bar = @engine.heap.root.find_child( 'bar' )

    node, source_fs = extractor.extract( bar, [ fs ] )

    assert_equal 'bar', node.name
    refute_includes source_fs.roots, bar
  end

  # -------------------------------------------------------------------
  #   No owning file: build a fresh node
  # -------------------------------------------------------------------

  def test_builds_a_fresh_node_for_an_object_with_no_file
    o = Gloo::Objs::String.new( @engine )
    o.name = 'standalone'
    o.set_value( 'hi' )

    node, source_fs = extractor.extract( o, [] )

    refute @engine.error?
    assert_nil source_fs
    assert_equal 'standalone', node.name
    assert_equal 'string', node.raw_type
    assert_same o, node.obj
  end

  def test_fresh_node_for_a_never_loaded_nested_object_uses_its_dotted_path
    fs = load_fixture( 'app', <<~GLOO )
      app [can] :
        core [can] :
          other [string] : hi
    GLOO
    core = fs.obj.find_child( 'core' )
    fresh = @engine.factory.create( :name => 'new_thing', :type => 'string', :parent => core )

    node, source_fs = extractor.extract( fresh, [ fs ] )

    assert_nil source_fs
    assert_equal 'app.core.new_thing', node.name
    # the old file is untouched -- 'other' is still there
    core_node = fs.source_doc.children.first.children.first
    assert_equal [ 'other' ], core_node.children.map( &:name )
  end

  # -------------------------------------------------------------------
  #   Errors
  # -------------------------------------------------------------------

  def test_errors_when_the_subtree_spans_more_than_one_file
    fs_a = load_fixture( 'file_a', <<~GLOO )
      app [can] :
        core [can] :
          settings [can] :
            theme [string] : dark
    GLOO
    settings = fs_a.obj.find_child( 'core' ).find_child( 'settings' )

    fs_b = load_fixture( 'file_b', <<~GLOO )
      app [can] :
        core [can] :
          settings [can] :
            volume [string] : loud
    GLOO

    node, source_fs = extractor.extract( settings, [ fs_a, fs_b ] )

    assert @engine.error?
    assert_nil node
    assert_nil source_fs
  end

  def test_errors_when_obj_has_no_declaration_of_its_own_to_move
    fs = load_fixture( 'app', <<~GLOO )
      app.core.settings [can] :
        theme [string] : dark
    GLOO
    # 'core' is an intermediate container ShorthandExpander created --
    # it never got a source node of its own, only 'settings' did.
    core = fs.obj.find_child( 'core' )

    node, source_fs = extractor.extract( core, [ fs ] )

    assert @engine.error?
    assert_nil node
    assert_nil source_fs
  end

end
