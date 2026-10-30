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
    assert_nil n.obj
    assert_equal '', n.raw
    assert_nil n.home
    assert_nil n.repaired_head
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


  def test_text_is_the_doc_the_declaration_and_its_children
    n = Gloo::Persist::Source::ObjNode.new( :name => 'a', :raw_type => 'can' )
    n.leading_doc = "# doc\n"
    n.raw = "a [can] :\n"
    child = Gloo::Persist::Source::ObjNode.new( :name => 'b', :raw_type => 'int' )
    child.raw = "  b [int] : 1\n"
    n.children << child
    n.children << Gloo::Persist::Source::BlankNode.new( "\n" )
    assert_equal "# doc\na [can] :\n  b [int] : 1\n\n", n.text
  end

  def test_remember_in_place_and_changed
    can = @engine.factory.create_can( 'c', @engine.heap.root )
    o = @engine.factory.create_int( 'x', 1, can )
    n = Gloo::Persist::Source::ObjNode.new( :name => 'x', :raw_type => 'int' )
    n.obj = o
    n.remember
    assert n.in_place?
    refute n.changed?
    o.set_value( 2 )
    assert n.changed?
    can.remove_child( o )
    refute n.in_place?
  end

  def test_a_snapshot_is_not_changed_by_a_change_in_place
    s = Gloo::Objs::Script.new( @engine )
    s.set_array_value [ 'show 1' ]
    @engine.heap.root.add_child( s )
    n = Gloo::Persist::Source::ObjNode.new( :name => 's', :raw_type => 'script' )
    n.obj = s
    n.remember
    s.value << 'show 2'
    assert n.changed?
  end

  def test_rename_and_reindent
    n = Gloo::Persist::Source::ObjNode.new( :name => 'b', :raw_type => 'script' )
    n.raw_indent = '    '
    n.head = '    b [script]'
    n.leading_doc = "    # doc\n"
    n.raw = "    b [script] :\n      show 1\n\n"
    n.block_style = :body
    n.rename( 'a.b' )
    n.reindent( '' )
    assert_equal "# doc\n", n.leading_doc
    assert_equal "a.b [script] :\n  show 1\n\n", n.raw
    assert_equal 'a.b [script]', n.head
  end

  def test_reindent_leaves_block_content_and_lines_up_end
    n = Gloo::Persist::Source::ObjNode.new( :name => 't', :raw_type => 'text' )
    n.raw_indent = '  '
    n.block_style = :begin_end
    n.raw = "  t [text] : BEGIN\n  keep\nthis\n  END\n"
    n.reindent( "\t\t" )
    assert_equal "\t\tt [text] : BEGIN\n  keep\nthis\n\t\tEND\n", n.raw
  end

  def test_detached_has_no_children_and_leaves_the_node_alone
    n = Gloo::Persist::Source::ObjNode.new( :name => 'a', :raw_type => 'can' )
    n.raw = "a [can] :\n"
    n.children << Gloo::Persist::Source::BlankNode.new( "\n" )
    copy = n.detached( "a [can] : x\n" )
    assert_equal [], copy.children
    assert_equal "a [can] : x\n", copy.raw
    assert_equal "a [can] :\n", n.raw
    assert_equal 1, n.children.size
  end

end
