require 'test_helper'
require 'tmpdir'

class FileStyleTest < BaseEngineTest

  #
  # Load text from a scratch file and return its source document.
  #
  def doc_for( text )
    @dir = Dir.mktmpdir
    File.write( File.join( @dir, 't.gloo' ), text )
    @engine.persist_man.load( File.join( @dir, 't.gloo' ) )
    return @engine.persist_man.maps.last.source_doc
  end

  def teardown
    FileUtils.remove_entry @dir if @dir
    super
  end

  def test_a_new_file_uses_two_spaces_and_type_names
    style = Gloo::Persist::FileStyle.new( @engine )
    assert_equal '  ', style.unit
    assert_equal 'integer', style.type_for( Gloo::Objs::Integer.new( @engine ) )
  end

  def test_the_unit_is_the_step_in_to_the_first_child
    assert_equal "\t", Gloo::Persist::FileStyle.new( @engine, doc_for( "a [can] :\n\tb [int] : 1\n" ) ).unit
  end

  def test_four_spaces_are_kept_as_the_unit
    assert_equal '    ', Gloo::Persist::FileStyle.new( @engine, doc_for( "a [can] :\n    b [int] : 1\n" ) ).unit
  end

  def test_a_type_is_spelled_the_way_the_file_spells_it_most
    style = Gloo::Persist::FileStyle.new( @engine,
      doc_for( "a [can] :\n  b [int] : 1\n  c [int] : 2\n  d [integer] : 3\n" ) )
    assert_equal 'int', style.type_for( Gloo::Objs::Integer.new( @engine ) )
    assert_equal 'can', style.type_for( Gloo::Objs::Container.new( @engine ) )
    assert_equal 'string', style.type_for( Gloo::Objs::String.new( @engine ) )
  end

  def test_an_untyped_declaration_without_brackets_is_spelled_without
    style = Gloo::Persist::FileStyle.new( @engine, doc_for( "a [can] :\n  plain : x\n" ) )
    assert_nil style.type_for( Gloo::Objs::Untyped.new( @engine ) )
  end

end
