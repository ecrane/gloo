require 'test_helper'
require 'tmpdir'

class EachDirTest < BaseEngineTest

  def setup
    super
    @root = Dir.mktmpdir( 'gloo_each_dir' )
    build_tree
  end

  def teardown
    FileUtils.rm_rf( @root )
    super
  end

  #
  # A nested tree with a hidden folder, a file and a symlinked folder.
  #
  def build_tree
    FileUtils.mkdir_p( File.join( @root, 'a', 'deep' ) )
    FileUtils.mkdir_p( File.join( @root, 'b', '.hidden' ) )
    FileUtils.mkdir_p( File.join( @root, 'target', 'inner' ) )
    FileUtils.touch( File.join( @root, 'top.md' ) )
    File.symlink( File.join( @root, 'target' ), File.join( @root, 'link' ) )
  end

  #
  # Create an each dir loop and collect the paths it gives.
  #
  def walk( folder, recursive: nil )
    fac = @engine.factory
    root = @engine.heap.root
    old = root.find_child( 'for' )
    root.remove_child( old ) if old
    obj = fac.create( { :name => 'for', :type => 'each', :value => nil, :parent => root } )
    fac.create_file 'dir', '', obj
    fac.create_string 'in', folder, obj
    fac.create_bool 'recursive', recursive, obj unless recursive.nil?

    found = []
    obj.define_singleton_method( :run_do ) { found << find_child( 'dir' ).value }
    Gloo::Objs::EachDir.new( @engine, obj ).run
    return found.map { |f| f.delete_prefix( "#{@root}/" ) }
  end

  def test_use_for
    i = @engine.parser.parse_immediate 'create for as each'
    i.run
    i = @engine.parser.parse_immediate 'tell for.word to unload'
    i.run
    i = @engine.parser.parse_immediate 'create for.dir as string'
    i.run

    obj = @engine.heap.root.children.first
    assert obj

    assert Gloo::Objs::EachDir.use_for?( obj )
    refute Gloo::Objs::EachChild.use_for?( obj )
    refute Gloo::Objs::EachFile.use_for?( obj )
    refute Gloo::Objs::EachLine.use_for?( obj )
    refute Gloo::Objs::EachWord.use_for?( obj )
  end

  def test_one_level
    assert_equal [ 'a', 'b', 'link', 'target' ], walk( "#{@root}/" )
  end

  def test_trailing_slash_is_optional
    assert_equal [ 'a', 'b', 'link', 'target' ], walk( @root )
  end

  def test_recursive
    assert_equal [ 'a', 'a/deep', 'b', 'link', 'target', 'target/inner' ],
      walk( @root, recursive: true )
  end

  def test_wildcard_in_folder
    # A single-level * goes through the symlinked folder; only ** does not.
    assert_equal [ 'a/deep', 'link/inner', 'target/inner' ], walk( "#{@root}/*/" )
  end

  def test_missing_folder_is_an_error
    assert_equal [], walk( File.join( @root, 'nope' ) )
    assert @engine.error?
  end

  def test_missing_wildcard_folder_is_not_an_error
    assert_equal [], walk( File.join( @root, 'nope', '**' ) )
    refute @engine.error?
  end

  def test_tilde_expands_to_home
    home = ENV[ 'HOME' ]
    ENV[ 'HOME' ] = @root
    assert_equal [ 'a/deep' ], walk( '~/a' )
    refute @engine.error?
  ensure
    ENV[ 'HOME' ] = home
  end

end
