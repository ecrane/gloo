require 'test_helper'

class PersistManTest < BaseEngineTest

  def test_that_the_engine_has_persistence_manager
    assert @engine.persist_man
  end

  def test_construction
    o = GlooLang::Persist::PersistMan.new( @engine )
    assert o
    assert_equal 0, o.maps.count
  end

  def test_mech_added_during_construction
    o = GlooLang::Persist::PersistMan.new( @engine )
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

end
