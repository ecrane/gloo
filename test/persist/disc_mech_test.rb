require 'test_helper'

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

end