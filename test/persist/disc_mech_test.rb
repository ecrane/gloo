require 'test_helper'
require 'tmpdir'

class DiscMechTest < BaseEngineTest

  def test_disc_mech_constructor
    o = Gloo::Persist::DiscMech.new( @engine )
    assert o
  end

  def test_getting_all_files_in
    o = Gloo::Persist::DiscMech.new( @engine )
    arr = o.get_all_files_in( '' )
    assert arr
    assert_equal 2, arr.count
  end

  def test_valid_check
    o = Gloo::Persist::DiscMech.new( @engine )
    refute o.valid?( nil )
    refute o.valid?( '' )
    refute o.valid?( 'blark' )

    f = File.join( @engine.settings.project_path, 'test' )
    refute o.valid?( f )
    f = "#{f}.gloo"
    assert o.valid?( f )

    f = File.join( @engine.settings.project_path, 'sub' )
    refute o.valid?( f )
  end

  def test_expanding_file
    o = Gloo::Persist::DiscMech.new( @engine )
    f = o.expand( 'test' )
    assert f
    f = f.first
    assert f.end_with?( 'test.gloo' )
  end

  def test_reading_a_file
    o = Gloo::Persist::DiscMech.new( @engine )
    f = o.expand( 'test' ).first
    assert f
    data = o.read( f )
    assert data
    assert data.length > 10
    assert data.start_with?( 'test' )
  end

  def test_resolve_save_path_appends_extension_and_joins_project_root
    o = Gloo::Persist::DiscMech.new( @engine )
    pn = o.resolve_save_path( 'brand_new' )
    assert_equal File.join( @engine.settings.project_path, 'brand_new.gloo' ), pn
  end

  def test_resolve_save_path_does_not_double_up_the_extension
    o = Gloo::Persist::DiscMech.new( @engine )
    pn = o.resolve_save_path( 'brand_new.gloo' )
    assert_equal File.join( @engine.settings.project_path, 'brand_new.gloo' ), pn
  end

  def test_resolve_save_path_does_not_require_the_file_to_exist
    o = Gloo::Persist::DiscMech.new( @engine )
    pn = o.resolve_save_path( 'nothing_here_yet' )
    refute o.exist?( pn )
    assert pn.end_with?( 'nothing_here_yet.gloo' )
  end

  def test_resolve_save_path_leaves_an_absolute_path_alone
    o = Gloo::Persist::DiscMech.new( @engine )
    pn = o.resolve_save_path( '/tmp/somewhere/thing' )
    assert_equal '/tmp/somewhere/thing.gloo', pn
  end

  # ---------------------------------------------------------------------
  #    A wildcard folder given as an absolute or ~ path
  # ---------------------------------------------------------------------

  def test_getting_all_files_in_an_absolute_folder
    with_wild_dir do |dir|
      arr = Gloo::Persist::DiscMech.new( @engine ).get_all_files_in( "#{dir}/" )
      assert_equal %w[a.gloo b.gloo], arr.map { |f| File.basename( f ) }.sort
    end
  end

  def test_getting_files_with_a_prefix_in_an_absolute_folder
    with_wild_dir do |dir|
      arr = Gloo::Persist::DiscMech.new( @engine ).get_all_files_in( "#{dir}/a" )
      assert_equal %w[a.gloo], arr.map { |f| File.basename( f ) }
    end
  end

  def test_getting_all_files_in_a_home_folder
    home_dir = File.join( Dir.home, 'gloo_wild_test_xyz' )
    FileUtils.mkdir_p( home_dir )
    File.write( File.join( home_dir, 'a.gloo' ), "a [can] :\n" )
    File.write( File.join( home_dir, 'b.gloo' ), "b [can] :\n" )
    arr = Gloo::Persist::DiscMech.new( @engine ).get_all_files_in( '~/gloo_wild_test_xyz/' )
    assert_equal %w[a.gloo b.gloo], arr.map { |f| File.basename( f ) }.sort
  ensure
    FileUtils.remove_entry( home_dir, true )
  end

  def test_a_missing_absolute_folder_finds_nothing
    with_wild_dir do |dir|
      assert_equal [], Gloo::Persist::DiscMech.new( @engine ).get_all_files_in( "#{dir}/nope/" )
    end
  end

  private

  #
  # Yield a scratch folder holding a.gloo, b.gloo and c.txt.
  #
  def with_wild_dir
    dir = Dir.mktmpdir
    File.write( File.join( dir, 'a.gloo' ), "a [can] :\n" )
    File.write( File.join( dir, 'b.gloo' ), "b [can] :\n" )
    File.write( File.join( dir, 'c.txt' ), "not gloo\n" )
    yield dir
  ensure
    FileUtils.remove_entry dir if dir
  end

end
