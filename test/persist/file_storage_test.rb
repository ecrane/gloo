require 'test_helper'

class FileStorageTest < BaseEngineTest

  def test_loading_a_file
    pn = @engine.persist_man.get_full_path_names( 'test' ).first
    fs = Gloo::Persist::FileStorage.new( @engine, pn )
    fs.load
    assert fs.obj
    assert_equal 'test', fs.obj.name
  end

  def test_constructor_accepts_a_prebuilt_source_doc
    o = Gloo::Objs::String.new( @engine )
    doc = Gloo::Persist::Source::SourceDoc.new
    fs = Gloo::Persist::FileStorage.new( @engine, '/tmp/x.gloo', o, doc )
    assert_same o, fs.obj
    assert_equal [ o ], fs.roots
    assert_same doc, fs.source_doc
  end

  def test_drop_root_removes_from_roots
    a = Gloo::Objs::String.new( @engine )
    b = Gloo::Objs::String.new( @engine )
    fs = Gloo::Persist::FileStorage.new( @engine, '/tmp/x.gloo', a )
    fs.roots << b

    fs.drop_root( b )
    assert_equal [ a ], fs.roots
  end

  def test_drop_root_repoints_obj_to_a_remaining_root_when_it_was_the_dropped_one
    a = Gloo::Objs::String.new( @engine )
    b = Gloo::Objs::String.new( @engine )
    fs = Gloo::Persist::FileStorage.new( @engine, '/tmp/x.gloo', a )
    fs.roots << b

    fs.drop_root( a )
    assert_same b, fs.obj
    assert_equal [ b ], fs.roots
  end

  def test_drop_root_leaves_obj_nil_when_no_roots_remain
    a = Gloo::Objs::String.new( @engine )
    fs = Gloo::Persist::FileStorage.new( @engine, '/tmp/x.gloo', a )

    fs.drop_root( a )
    assert_nil fs.obj
    assert_equal [], fs.roots
  end

end
