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

end
