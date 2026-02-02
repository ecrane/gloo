require 'test_helper'

class EachChildTest < BaseEngineTest

  def create_for_each_child
    i = @engine.parser.parse_immediate 'create for as each'
    i.run
    i = @engine.parser.parse_immediate 'tell for.word to unload'
    i.run
    i = @engine.parser.parse_immediate 'create for.child as alias'
    i.run

    return @engine.heap.root.children.first
  end

  def test_use_for
    obj = create_for_each_child
    assert obj

    assert Gloo::Objs::EachChild.use_for?( obj )
    refute Gloo::Objs::EachFile.use_for?( obj )
    refute Gloo::Objs::EachLine.use_for?( obj )
    refute Gloo::Objs::EachWord.use_for?( obj )
  end

  def test_getting_group_by_value
    obj = create_for_each_child
    assert obj
    
    iterator = Gloo::Objs::EachChild.new( @engine, obj )
    assert iterator

    group_by_value = iterator.group_by_value(nil)
    assert_nil group_by_value
    refute iterator.has_group_by?

    i = @engine.parser.parse_immediate 'create for.group_by as string'
    i.run

    group_by_value = iterator.group_by_value(nil)
    refute group_by_value
    assert iterator.has_group_by?

    i = @engine.parser.parse_immediate 'put "wow" into for.group_by'
    i.run
    assert iterator.has_group_by?
  end

end
