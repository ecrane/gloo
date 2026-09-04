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

end
