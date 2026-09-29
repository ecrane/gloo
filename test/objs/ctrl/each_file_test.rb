require 'test_helper'
require 'tmpdir'

class EachFileTest < BaseEngineTest

  def setup
    super
    @root = Dir.mktmpdir( 'gloo_each_file' )
    build_tree
  end

  def teardown
    FileUtils.rm_rf( @root )
    super
  end

  #
  # A nested tree: files at the top and in subfolders, hidden files
  # and folders, a wrong extension, an uppercase extension and a
  # symlinked folder.
  #
  def build_tree
    FileUtils.mkdir_p( File.join( @root, 'a', 'deep' ) )
    FileUtils.mkdir_p( File.join( @root, 'b', '.hidden' ) )
    FileUtils.mkdir_p( File.join( @root, '.obs' ) )
    FileUtils.mkdir_p( File.join( @root, 'target' ) )
    [ 'top.md', 'notes.txt', '.dot.md', 'a/x.md', 'a/deep/y.md',
      'b/Upper.MD', 'b/.hidden/h.md', '.obs/o.md', 'target/t.md' ].each do |f|
      FileUtils.touch( File.join( @root, f ) )
    end
    File.symlink( File.join( @root, 'target' ), File.join( @root, 'link' ) )
  end

  #
  # Create an each file loop and collect the paths it gives.
  #
  def walk( folder, ext: nil, recursive: nil, include_dirs: nil )
    fac = @engine.factory
    root = @engine.heap.root
    old = root.find_child( 'for' )
    root.remove_child( old ) if old
    obj = fac.create( { :name => 'for', :type => 'each', :value => nil, :parent => @engine.heap.root } )
    fac.create_file 'file', '', obj
    fac.create_string 'in', folder, obj
    fac.create_string 'ext', ext, obj unless ext.nil?
    fac.create_bool 'recursive', recursive, obj unless recursive.nil?
    fac.create_bool 'include_dirs', include_dirs, obj unless include_dirs.nil?

    found = []
    obj.define_singleton_method( :run_do ) { found << find_child( 'file' ).value }
    Gloo::Objs::EachFile.new( @engine, obj ).run
    return found.map { |f| f.delete_prefix( "#{@root}/" ) }
  end

  def test_use_for
    i = @engine.parser.parse_immediate 'create for as each'
    i.run
    i = @engine.parser.parse_immediate 'tell for.word to unload'
    i.run
    i = @engine.parser.parse_immediate 'create for.file as file'
    i.run

    obj = @engine.heap.root.children.first
    assert obj

    assert Gloo::Objs::EachFile.use_for?( obj )
    refute Gloo::Objs::EachChild.use_for?( obj )
    refute Gloo::Objs::EachLine.use_for?( obj )
    refute Gloo::Objs::EachWord.use_for?( obj )
  end

  def test_files_only_by_default
    assert_equal [ 'notes.txt', 'top.md' ], walk( "#{@root}/" )
  end

  def test_include_dirs
    assert_equal [ 'a', 'b', 'link', 'notes.txt', 'target', 'top.md' ],
      walk( "#{@root}/", include_dirs: true )
  end

  def test_trailing_slash_is_optional
    assert_equal walk( "#{@root}/" ), walk( @root )
  end

  def test_no_trailing_slash_does_not_match_siblings
    FileUtils.touch( "#{@root}_sibling.md" )
    assert_equal [ 'notes.txt', 'top.md' ], walk( @root )
  ensure
    FileUtils.rm_f( "#{@root}_sibling.md" )
  end

  def test_ext
    assert_equal [ 'top.md' ], walk( @root, ext: 'md' )
  end

  def test_ext_ignores_case_and_leading_dot
    assert_equal [ 'b/Upper.MD' ], walk( "#{@root}/b", ext: 'md' )
    assert_equal [ 'b/Upper.MD' ], walk( "#{@root}/b", ext: '.MD' )
  end

  def test_recursive
    assert_equal [ 'a/deep/y.md', 'a/x.md', 'b/Upper.MD', 'target/t.md', 'top.md' ],
      walk( @root, ext: 'md', recursive: true )
  end

  def test_recursive_skips_hidden_and_symlinked_folders
    found = walk( @root, recursive: true )
    refute found.any? { |f| f.split( '/' ).any? { |part| part.start_with?( '.' ) } }
    refute found.any? { |f| f.start_with?( 'link/' ) }
  end

  def test_recursive_include_dirs_lists_parents_before_children
    found = walk( @root, recursive: true, include_dirs: true )
    assert_includes found, 'a/deep'
    assert found.index( 'a' ) < found.index( 'a/deep' )
    assert found.index( 'a/deep' ) < found.index( 'a/deep/y.md' )
  end

  def test_wildcard_in_folder
    assert_equal [ 'a/deep/y.md', 'a/x.md', 'b/Upper.MD', 'target/t.md', 'top.md' ],
      walk( "#{@root}/**/", ext: 'md' )
  end

  def test_recursive_with_wildcard_folder_is_harmless
    assert_equal walk( "#{@root}/**/", ext: 'md' ),
      walk( "#{@root}/**/", ext: 'md', recursive: true ).uniq
  end

  def test_tilde_expands_to_home
    home = ENV[ 'HOME' ]
    ENV[ 'HOME' ] = @root
    assert_equal [ 'a/x.md' ], walk( '~/a', ext: 'md' )
  ensure
    ENV[ 'HOME' ] = home
  end

  def test_relative_folder_stays_relative
    Dir.chdir( @root ) do
      assert_equal [ 'a/x.md' ], walk( 'a', ext: 'md' )
    end
  end

end
