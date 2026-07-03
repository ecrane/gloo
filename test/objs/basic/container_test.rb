require 'test_helper'

class ContainerTest < BaseEngineTest

  def test_the_typename
    assert_equal 'container', Gloo::Objs::Container.typename
  end

  def test_the_short_typename
    assert_equal 'can', Gloo::Objs::Container.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'container' )
    assert @dic.find_obj( 'CONTAINER' )
    assert @dic.find_obj( 'can' )
    assert @dic.find_obj( 'CAN' )
  end

  def test_messages
    msgs = Gloo::Objs::Container.messages
    assert msgs
    assert msgs.include?( 'count' )
    assert msgs.include?( 'delete_children' )
    assert msgs.include?( 'unload' )
    assert msgs.include?( 'show_key_value_table' )
  end

  def test_count_msg
    o = Gloo::Objs::Container.new @engine
    assert_equal 0, o.msg_count
    o.add_child o
    assert_equal 1, o.msg_count
  end

  def test_doesnt_add_children_on_create
    o = Gloo::Objs::Container.new @engine
    refute o.add_children_on_create?
  end

  def test_running_evaluated_string
    s = 'create c as can'
    @engine.parser.parse_immediate( s ).run
    can = @engine.heap.root.children.first

    s = 'create c.x as int'
    @engine.parser.parse_immediate( s ).run
    s = 'create c.y as int'
    @engine.parser.parse_immediate( s ).run
    s = 'create c.z as int'
    @engine.parser.parse_immediate( s ).run

    assert_equal 3, can.child_count

    s = 'tell c to delete_children'
    @engine.parser.parse_immediate( s ).run
    assert_equal 0, can.child_count
  end

  def test_child_exists_msg
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.x as int'
    @engine.parser.run "check c for child_exists ('x')"
    assert @engine.heap.it.value

    @engine.parser.run "check c for child_exists ('z')"
    refute @engine.heap.it.value
  end

  def test_that_it_is_a_container
    o = Gloo::Objs::Container.new @engine
    assert o.is_container?
  end

end
