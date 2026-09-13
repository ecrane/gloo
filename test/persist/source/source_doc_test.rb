require 'test_helper'

class SourceDocTest < BaseEngineTest

  def test_starts_empty
    doc = Gloo::Persist::Source::SourceDoc.new
    assert_equal [], doc.children
    assert_equal [], doc.roots
  end

  def test_roots_selects_only_obj_nodes
    doc = Gloo::Persist::Source::SourceDoc.new
    doc.children << Gloo::Persist::Source::CommentNode.new( '# hi' )
    a = Gloo::Persist::Source::ObjNode.new( :name => 'a', :raw_type => 'can' )
    doc.children << a
    doc.children << Gloo::Persist::Source::BlankNode.new
    b = Gloo::Persist::Source::ObjNode.new( :name => 'b', :raw_type => 'string' )
    doc.children << b

    assert_equal [ a, b ], doc.roots
  end

  # -------------------------------------------------------------------
  #   #extract -- find and remove a node by its heap object
  # -------------------------------------------------------------------

  def test_extract_removes_and_returns_a_top_level_node
    doc = Gloo::Persist::Source::SourceDoc.new
    o = Gloo::Objs::String.new( @engine )
    a = Gloo::Persist::Source::ObjNode.new( :name => 'a', :raw_type => 'string' )
    a.obj = o
    doc.children << a

    found = doc.extract( o )
    assert_same a, found
    assert_equal [], doc.children
  end

  def test_extract_finds_a_deeply_nested_node_and_leaves_siblings_alone
    doc = Gloo::Persist::Source::SourceDoc.new
    parent = Gloo::Persist::Source::ObjNode.new( :name => 'parent', :raw_type => 'can' )
    parent.obj = Gloo::Objs::Container.new( @engine )
    doc.children << parent

    o = Gloo::Objs::String.new( @engine )
    target = Gloo::Persist::Source::ObjNode.new( :name => 'target', :raw_type => 'string' )
    target.obj = o
    sibling = Gloo::Persist::Source::BlankNode.new
    parent.children << sibling
    parent.children << target

    found = doc.extract( o )
    assert_same target, found
    assert_equal [ sibling ], parent.children
  end

  def test_extract_returns_nil_when_no_node_matches
    doc = Gloo::Persist::Source::SourceDoc.new
    o = Gloo::Objs::String.new( @engine )
    assert_nil doc.extract( o )
  end

end
