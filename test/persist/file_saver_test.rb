require 'test_helper'
require 'tmpdir'

class FileSaverTest < BaseEngineTest

  def setup
    super
    @tmp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry @tmp_dir
    super
  end

  #
  # Load a fixture, save it (unchanged or after the block edits it) to
  # a scratch path -- never back onto the fixture itself -- and return
  # the resulting file contents.
  #
  def round_trip( fixture )
    @engine.persist_man.load fixture
    fs = @engine.persist_man.maps.last
    yield fs.obj if block_given?

    out = File.join( @tmp_dir, 'out.gloo' )
    saver = Gloo::Persist::FileSaver.new( @engine, out, fs.obj, fs.source_doc )
    saver.save
    return File.read( out )
  end

  def original( fixture )
    return File.read( @engine.persist_man.get_full_path_names( fixture ).first )
  end

  def test_round_trip_is_byte_identical_for_comments_fixture
    assert_equal original( 'sub/comments' ), round_trip( 'sub/comments' )
  end

  def test_round_trip_is_byte_identical_for_begin_end_block_fixture
    assert_equal original( 'sub/block_lines' ), round_trip( 'sub/block_lines' )
  end

  def test_round_trip_is_byte_identical_for_empty_script_fixture
    assert_equal original( 'sub/empty_script' ), round_trip( 'sub/empty_script' )
  end

  def test_round_trip_is_byte_identical_for_multi_root_fixture
    assert_equal original( 'ctrl/invoke' ), round_trip( 'ctrl/invoke' )
  end

  def test_round_trip_rerenders_only_the_changed_value
    out = round_trip( 'sub/comments' ) do |demo|
      demo.find_child( 'msg' ).set_value( 'goodbye' )
    end

    assert_includes out, '# leading doc comment for demo'
    assert_includes out, '# leading doc for msg'
    assert_includes out, '# detached from other'
    assert_includes out, 'msg [string] : goodbye'
    refute_includes out, 'msg [string] : hello'
    assert_includes out, 'other [string] : world'
  end

  def test_round_trip_drops_a_deleted_object
    out = round_trip( 'sub/comments' ) do |demo|
      demo.remove_child( demo.find_child( 'other' ) )
    end

    refute_includes out, 'other [string]'
    assert_includes out, 'msg [string] : hello'
  end

  def test_round_trip_appends_a_new_object
    out = round_trip( 'sub/comments' ) do |demo|
      @engine.factory.create_string( 'extra', 'new value', demo )
    end

    assert_includes out, 'msg [string] : hello'
    assert_includes out, 'extra [string] : new value'
    # appended after the existing content, not spliced into the middle
    assert out.index( 'extra [string]' ) > out.index( 'other [string]' )
  end

  def test_round_trip_preserves_script_body_indentation_and_comments
    out = round_trip( 'sub/empty_script' )
    assert_includes out, "\t\t# just a note, no commands"
  end

  def test_round_trip_falls_back_to_regeneration_with_no_source_doc
    o = @engine.factory.create( { :name => 'fresh', :type => 'can' } )
    @engine.factory.create( { :name => 's', :type => 'str', :value => 'hi', :parent => o } )

    out_path = File.join( @tmp_dir, 'fresh.gloo' )
    saver = Gloo::Persist::FileSaver.new( @engine, out_path, o )
    saver.save

    assert_equal "fresh [container] : \n\ts [string] : hi\n", File.read( out_path )
  end

  def test_getting_simple_object
    o = @engine.factory.create(
      { :name => 's', :type => 'str', :value => 'one' } )
    assert o

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    assert fs

    str = fs.get_obj o
    assert_equal "s [string] : one\n", str
  end

  def test_getting_a_container_with_children
    c = @engine.factory.create( { :name => 'c', :type => 'can' } )
    @engine.factory.create( { :name => 's', :type => 'str', :value => 'one',
                               :parent => c } )
    assert c

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    str = fs.get_obj c
    assert_equal "c [container] : \n\ts [string] : one\n", str
  end

  def test_getting_a_script_with_multiple_lines
    o = Gloo::Objs::Script.new @engine
    o.name = 's'
    o.set_array_value [ 'show 2 + 3', 'show 1 + 2' ]

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    str = fs.get_obj o
    assert_equal "s [script] :\n\tshow 2 + 3\n\tshow 1 + 2\n", str
  end

  def test_getting_a_multiline_string_value_as_begin_end_block
    o = @engine.factory.create(
      { :name => 't', :type => 'str', :value => "line one\nline two" } )

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    str = fs.get_obj o
    assert_equal "t [string] : BEGIN\n\tline one\n\tline two\nEND\n", str
  end

  def test_tabs
    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )

    assert_equal '', fs.tabs
    assert_equal '', fs.tabs( 0 )
    assert_equal "\t", fs.tabs( 1 )
    assert_equal "\t\t", fs.tabs( 2 )
  end

end
