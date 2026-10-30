require 'test_helper'

class DeclarationWriterTest < BaseEngineTest

  def writer
    return Gloo::Persist::DeclarationWriter.new( @engine, Gloo::Persist::FileStyle.new( @engine ) )
  end

  #
  # A new string object with the given value, under the heap root.
  #
  def string( value, name = 's' )
    o = Gloo::Objs::String.new( @engine )
    o.name = name
    o.set_value( value )
    @engine.heap.root.add_child( o )
    return o
  end

  def test_a_new_value_on_one_line
    assert_equal "  s [string] : hi\n", writer.new_node( string( 'hi' ), '  ' ).raw
  end

  def test_an_empty_value_has_no_trailing_space
    assert_equal "s [string] :\n", writer.new_node( string( '' ), '' ).raw
  end

  def test_a_multi_line_value_is_a_block_written_exactly
    node = writer.new_node( string( "  one\ntwo\n" ), '  ' )
    assert_equal "  s [string] : BEGIN\n  one\ntwo\n  END\n", node.raw
    assert_equal :begin_end, node.block_style
  end

  def test_a_value_ending_in_a_backslash_is_a_block
    raw = nil
    warnings = capture_warnings { raw = writer.new_node( string( 'C:\\' ), '' ).raw }
    assert_equal "s [string] : BEGIN\nC:\\\nEND\n", raw
    assert warnings.any? { |w| w.include?( 'a block value always ends with a newline' ) }
  end

  def test_a_value_ending_in_begin_is_a_block
    raw = nil
    capture_warnings { raw = writer.new_node( string( 'go BEGIN' ), '' ).raw }
    assert_equal "s [string] : BEGIN\ngo BEGIN\nEND\n", raw
  end

  def test_a_line_that_is_just_end_warns
    warnings = capture_warnings { writer.new_node( string( "a\nEND\nb\n" ), '' ) }
    assert warnings.any? { |w| w.include?( 'a line that is just END ends the block early' ) }
  end

  def test_invalid_utf8_warns
    warnings = capture_warnings { writer.new_node( string( "caf\xE9".dup.force_encoding( 'UTF-8' ) ), '' ) }
    assert warnings.any? { |w| w.include?( 'it is not valid UTF-8' ) }
  end

  def test_a_script_is_a_body_one_step_in
    o = Gloo::Objs::Script.new( @engine )
    o.name = 'go'
    o.set_array_value [ 'show 1', 'show 2' ]
    assert_equal "  go [script] :\n    show 1\n    show 2\n", writer.new_node( o, '  ' ).raw
  end

  def test_a_changed_value_keeps_the_head_and_separator_as_written
    node = Gloo::Persist::Source::ObjNode.new( :name => 'x', :raw_type => 'int' )
    node.head = '  x   [int]'
    node.raw_tail = ':1'
    node.raw_value = '1'
    node.raw_indent = '  '
    node.obj = @engine.factory.create_int( 'x', 2, @engine.heap.root )
    assert_equal "  x   [int]:2\n", writer.changed_text( node )
  end

end
