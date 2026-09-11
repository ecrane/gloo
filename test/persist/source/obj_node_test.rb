require 'test_helper'

class ObjNodeTest < BaseEngineTest

  def test_defaults
    n = Gloo::Persist::Source::ObjNode.new( :name => 'x', :raw_type => 'string' )
    assert_equal 'x', n.name
    assert_equal 'string', n.raw_type
    assert_equal '', n.raw_indent
    assert_equal :inline, n.block_style
    assert_nil n.raw_value
    assert_nil n.leading_doc
    assert_nil n.trailing_comment
    assert_nil n.obj
    assert_equal [], n.children
  end

  def test_holds_given_values
    o = Gloo::Objs::String.new @engine
    n = Gloo::Persist::Source::ObjNode.new( :name => 'x', :raw_type => 'str' )
    n.raw_indent = "\t"
    n.block_style = :begin_end
    n.raw_value = 'hi'
    n.leading_doc = '# doc'
    n.obj = o
    assert_equal "\t", n.raw_indent
    assert_equal :begin_end, n.block_style
    assert_equal 'hi', n.raw_value
    assert_equal '# doc', n.leading_doc
    assert_same o, n.obj
  end

  def test_children_can_be_appended
    n = Gloo::Persist::Source::ObjNode.new( :name => 'x', :raw_type => 'can' )
    child = Gloo::Persist::Source::ObjNode.new( :name => 'y', :raw_type => 'string' )
    n.children << child
    assert_equal [ child ], n.children
  end

  # -------------------------------------------------------------------
  #   #doc -- the cleaned-up leading_doc
  # -------------------------------------------------------------------

  def node_with_doc( raw )
    n = Gloo::Persist::Source::ObjNode.new( :name => 'x', :raw_type => 'string' )
    n.leading_doc = raw
    return n
  end

  def test_doc_is_blank_with_no_leading_doc
    n = Gloo::Persist::Source::ObjNode.new( :name => 'x', :raw_type => 'string' )
    assert_equal '', n.doc
  end

  def test_doc_strips_hash_and_one_space
    n = node_with_doc( "# Hello there.\n# Second line." )
    assert_equal "Hello there.\nSecond line.", n.doc
  end

  def test_doc_strips_leading_whitespace_before_the_hash
    n = node_with_doc( "\t\t# Indented comment." )
    assert_equal 'Indented comment.', n.doc
  end

  def test_doc_treats_a_bare_hash_as_a_blank_line
    n = node_with_doc( "#\n# Summary.\n#" )
    assert_equal "\nSummary.\n", n.doc
  end

  def test_doc_keeps_interior_blank_lines
    n = node_with_doc( "# First paragraph.\n#\n# Second paragraph." )
    assert_equal "First paragraph.\n\nSecond paragraph.", n.doc
  end

  def test_doc_keeps_blank_leading_and_trailing_lines
    n = node_with_doc( "#\n#\n# Padded on both sides.\n#\n#" )
    assert_equal "\n\nPadded on both sides.\n\n", n.doc
  end

  def test_doc_dedents_to_the_shallowest_line
    n = node_with_doc( "#   Summary line.\n#   - detail one\n#   - detail two" )
    assert_equal "Summary line.\n- detail one\n- detail two", n.doc
  end

  def test_doc_does_not_dedent_when_a_line_has_no_extra_indent
    n = node_with_doc( "# Summary line.\n#   - detail one" )
    assert_equal "Summary line.\n  - detail one", n.doc
  end

end
