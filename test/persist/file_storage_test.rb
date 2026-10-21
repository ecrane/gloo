require 'test_helper'
require 'tmpdir'

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

  def test_an_empty_file_warns_instead_of_erroring
    warnings = load_scratch_file( '' )
    refute @engine.error?, 'an empty file is not an error'
    assert_nil @fs.obj
    assert_equal 1, warnings.size
    assert_includes warnings.first, Gloo::Persist::FileStorage::NO_OBJECTS_WARNING
  end

  def test_a_comments_only_file_warns_instead_of_erroring
    warnings = load_scratch_file( "# a comment\n\n# another one\n" )
    refute @engine.error?, 'a comments-only file is not an error'
    assert_nil @fs.obj
    assert_equal 1, warnings.size
    assert_includes warnings.first, Gloo::Persist::FileStorage::NO_OBJECTS_WARNING
  end

  def test_the_warning_names_the_file
    warnings = load_scratch_file( "# a comment\n" )
    assert_includes warnings.first, @pn
  end

  def test_a_missing_file_is_still_an_error
    pn = File.join( Dir.tmpdir, 'gloo_no_such_file_xyz.gloo' )
    fs = Gloo::Persist::FileStorage.new( @engine, pn )
    warnings = capture_warnings { fs.load }
    assert @engine.error?
    assert_equal Gloo::Core::NotFound.file( pn ), @engine.heap.error.value,
                 'the not-found error should not be replaced by a vaguer one'
    assert_empty warnings
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

  def teardown
    FileUtils.remove_entry @dir if @dir
    super
  end

  private

  #
  # Write the given text to a scratch .gloo file, load it with a
  # FileStorage (kept in @fs, its path in @pn), and return the
  # warnings logged while loading.
  #
  def load_scratch_file( text )
    @dir = Dir.mktmpdir
    @pn = File.join( @dir, 'scratch.gloo' )
    File.write( @pn, text )
    @fs = Gloo::Persist::FileStorage.new( @engine, @pn )
    return capture_warnings { @fs.load }
  end

end
