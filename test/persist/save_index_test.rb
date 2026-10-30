require 'test_helper'
require 'tmpdir'

class SaveIndexTest < BaseEngineTest

  def setup
    super
    @dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry @dir
    super
  end

  #
  # Write and load a scratch file.
  #
  def load_file( name, text )
    path = File.join( @dir, "#{name}.gloo" )
    File.write( path, text )
    @engine.persist_man.load( path )
  end

  def index
    return Gloo::Persist::SaveIndex.new( @engine, @engine.persist_man.maps )
  end

  #
  # An object by path.
  #
  def obj( path )
    return Gloo::Core::Pn.new( @engine, path ).resolve
  end

  #
  # The declarations of an object, as nodes.
  #
  def nodes( idx, path )
    return idx.entries_for( obj( path ) ).map { |_, node| node }
  end

  def test_the_first_declaration_holds_the_value
    load_file 'a', "n [can] :\n  a [string] : First\n  a [string] : Second\n"
    idx = index
    first, second = nodes( idx, 'n.a' )
    assert idx.holder?( first )
    refute idx.holder?( second )
  end

  def test_a_declaration_of_a_deleted_object_does_not_stand
    load_file 'a', "n [can] :\n  a [can] :\n    b [int] : 1\n"
    a_node = nodes( index, 'n.a' ).first
    b_node = nodes( index, 'n.a.b' ).first
    @engine.parser.run 'tell n.a to unload'
    idx = index
    refute idx.standing?( a_node )
    refute idx.standing?( b_node ), 'nothing under a deleted declaration stands'
  end

  def test_a_moved_object_is_not_placed
    load_file 'a', "n [can] :\n  a [int] : 1\n  c [can] :\n"
    a = obj( 'n.a' )
    @engine.parser.run 'move n.a to n.c'
    idx = index
    refute idx.placed?( a )
    fs, node, prefix = idx.writer_for( obj( 'n.c' ) )
    assert_same @engine.persist_man.maps.last, fs
    assert_equal 'c', node.name
    assert_nil prefix
  end

  def test_a_new_child_of_the_heap_root_has_no_writer
    load_file 'a', "n [can] :\n"
    assert_nil index.writer_for( @engine.heap.root )
  end

  def test_a_container_named_only_by_shorthand_is_placed
    load_file 'a', "page.core.users [can] :\n"
    idx = index
    assert idx.placed?( obj( 'page.core' ) )
    refute idx.declared?( obj( 'page.core' ) )
    _fs, node, prefix = idx.writer_for( obj( 'page.core' ) )
    assert_equal 'page.core.users', node.name
    assert_equal 'page.core', prefix
  end

  def test_an_object_is_claimed_once
    idx = index
    o = @engine.factory.create_string( 'x', 'v', @engine.heap.root )
    assert idx.claim( o )
    refute idx.claim( o )
  end

end
