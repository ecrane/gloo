require 'test_helper'

class PersistManTest < BaseEngineTest

  def test_that_the_engine_has_persistence_manager
    assert @engine.persist_man
  end

  def test_construction
    o = Gloo::Persist::PersistMan.new( @engine )
    assert o
    assert_equal 0, o.maps.count
  end

  def test_mech_added_during_construction
    o = Gloo::Persist::PersistMan.new( @engine )
    assert o.mech
  end

  def test_file_ext
    o = @engine.persist_man.file_ext
    assert_equal '.gloo', o
  end

  def test_full_path_names
    o = @engine.persist_man.get_full_path_names 'test'
    assert o
    assert_equal 1, o.count
    e = o.first
    assert e
    assert e.end_with? '/test.gloo'
    assert e.start_with? @engine.settings.project_path
  end

  def test_load
    assert_equal 0, @engine.heap.root.child_count
    @engine.persist_man.load 'test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name
  end

  def test_if_file_is_gloo_file
    refute @engine.persist_man.gloo_file? '/a/b/c'
    refute @engine.persist_man.gloo_file? 'gloo'
    refute @engine.persist_man.gloo_file? @engine.settings.project_path

    o = @engine.persist_man.get_full_path_names 'test'
    assert @engine.persist_man.gloo_file? o[ 0 ]
  end

  def test_finding_file_storage
    @engine.parser.run 'load test'
    obj = @engine.heap.root.children.first
    fs = @engine.persist_man.find_file_storage( obj )

    assert fs
    assert_equal fs.obj.pn, obj.pn
  end

  def test_finding_file_storages_for_a_root
    @engine.parser.run 'load test'
    root = @engine.heap.root.children.first
    fs_list = @engine.persist_man.find_file_storages( root )

    assert_equal 1, fs_list.length
    assert_same root, fs_list.first.obj
  end

  def test_finding_file_storages_for_a_descendant_resolves_to_its_root
    @engine.parser.run 'load test'
    root = @engine.heap.root.children.first
    child = root.find_child( 'msg' )

    fs_list = @engine.persist_man.find_file_storages( child )
    assert_equal 1, fs_list.length
    assert_same root, fs_list.first.obj
  end

  def test_finding_file_storages_for_an_unmapped_object_is_empty
    o = @engine.factory.create( { :name => 'fresh', :type => 'can' } )
    assert_equal [], @engine.persist_man.find_file_storages( o )
  end

  #
  # Regression: an unhandled Ruby exception while loading a file (or
  # running its on_load script) used to crash the whole process, since
  # nothing in the load chain rescued it.
  #
  def test_load_survives_a_file_storage_exception
    original = Gloo::Persist::FileStorage.instance_method( :load )
    Gloo::Persist::FileStorage.send( :define_method, :load ) { raise 'boom' }

    begin
      @engine.persist_man.load 'test'
      assert_equal 0, @engine.heap.root.child_count
    ensure
      Gloo::Persist::FileStorage.send( :define_method, :load, original )
    end
  end

  def test_a_failed_load_is_not_added_to_the_maps
    @engine.persist_man.load 'no_such_file'
    assert_equal 0, @engine.persist_man.maps.count
  end

  #
  # Regression: loading a file that can't be resolved used to return
  # silently -- no log, no heap error, nothing on the console. It must
  # now report the failure so a CLI run doesn't look like a no-op.
  #
  def test_load_of_a_missing_file_reports_an_error
    refute @engine.error?
    result = @engine.persist_man.load 'no_such_file'

    refute result
    assert @engine.error?
    assert_equal 'File not found: no_such_file', @engine.heap.error.value
  end

  def test_load_of_a_good_file_returns_true
    assert_equal true, @engine.persist_man.load( 'test' )
    refute @engine.error?
  end

  def test_load_of_a_blank_name_does_not_report_an_error
    refute @engine.persist_man.load( '   ' )
    refute @engine.error?
  end

  def test_unload_removes_every_mapping_for_the_object
    @engine.parser.run 'load test'
    obj = @engine.heap.root.children.first

    # a second mapping for the same root (as save-to / a namespace would leave)
    extra = Gloo::Persist::FileStorage.new( @engine, '/tmp/gloo_extra.gloo', obj )
    @engine.persist_man.maps << extra
    assert_equal 2, @engine.persist_man.maps.count

    obj.msg_unload
    assert_equal 0, @engine.persist_man.maps.count
  end

  def test_unload_tolerates_a_mapping_whose_object_is_gone
    @engine.parser.run 'load test'
    obj = @engine.heap.root.children.first

    stale = Gloo::Persist::FileStorage.new( @engine, '/tmp/gloo_stale.gloo', nil )
    @engine.persist_man.maps << stale

    obj.msg_unload # used to raise NoMethodError on stale.obj.pn
    refute @engine.error?
    assert_equal 0, @engine.persist_man.maps.count
  end

  def test_reload_picks_up_an_external_change_to_the_file
    require 'tmpdir'
    dir = Dir.mktmpdir
    pn = File.join( dir, 'ext.gloo' )
    File.write( pn, "ext [container] :\n\tv [string] : first\n" )
    @engine.settings.override_project_path( "#{dir}/" )
    @engine.persist_man.load 'ext'
    assert_equal 'first', @engine.heap.root.find_child( 'ext' ).find_child( 'v' ).value

    # a change made outside gloo
    File.write( pn, "ext [container] :\n\tv [string] : second\n" )
    @engine.heap.root.find_child( 'ext' ).msg_reload

    assert_equal 'second', @engine.heap.root.find_child( 'ext' ).find_child( 'v' ).value
  ensure
    FileUtils.remove_entry dir if dir
  end

  def test_reload_of_a_deleted_file_does_not_corrupt_state
    require 'tmpdir'
    dir = Dir.mktmpdir
    pn = File.join( dir, 'gone.gloo' )
    File.write( pn, "gone [container] :\n\tv [string] : here\n" )
    @engine.settings.override_project_path( "#{dir}/" )
    @engine.persist_man.load 'gone'
    obj = @engine.heap.root.find_child( 'gone' )

    File.delete( pn )
    obj.msg_reload

    # the object is gone, but a later unload_all must not raise
    @engine.persist_man.unload_all
    refute @engine.error?
  ensure
    FileUtils.remove_entry dir if dir
  end

end
