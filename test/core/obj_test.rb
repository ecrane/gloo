require 'test_helper'

class ObjTest < BaseEngineTest

  def test_obj_creation
    o = Gloo::Core::Obj.new @engine
    assert o
  end

  def test_default_value
    o = Gloo::Core::Obj.new @engine
    assert o
    assert o.value
    assert_equal '', o.value
  end

  def test_obj_not_multiline_value
    o = Gloo::Core::Obj.new @engine
    refute o.multiline_value?
  end

  def test_default_container
    o = Gloo::Core::Obj.new @engine
    assert o
    assert o.children
    assert_equal 0, o.children.count
  end

  def test_setting_value
    o = Gloo::Core::Obj.new @engine
    o.value = 'test'
    assert_equal 'test', o.value
  end

  def test_value_is_string
    o = Gloo::Core::Obj.new @engine
    o.set_value 'test'
    assert o.value_string?
    o.set_value 1
    refute o.value_string?
  end

  def test_value_is_array
    o = Gloo::Core::Obj.new @engine
    o.set_value [ 'test' ]
    assert o.value_is_array?
    o.set_value 1
    refute o.value_is_array?
  end

  def test_value_is_blank
    o = Gloo::Core::Obj.new @engine
    o.set_value ''
    assert o.value_is_blank?
    o.set_value nil
    assert o.value_is_blank?
    o.set_value 'boo'
    refute o.value_is_blank?
  end

  def test_adding_children
    o = Gloo::Core::Obj.new @engine
    assert_equal 0, o.child_count
    s = Gloo::Objs::String.new @engine
    o.add_child s
    assert_equal 1, o.child_count
    assert_equal o, s.parent
  end

  def test_has_child_check
    o = Gloo::Core::Obj.new @engine
    s = Gloo::Objs::String.new @engine
    s.name = 'str'
    o.add_child s
    assert o.contains_child?( 'str' )
    refute o.contains_child?( 'x' )
  end

  def test_find_child
    o = Gloo::Objs::Container.new @engine
    s = Gloo::Objs::String.new @engine
    s.name = 'str'
    refute o.find_child( 'str' )
    o.add_child s
    assert_same s, o.find_child( 'str' )
  end

  def test_delete_children
    o = Gloo::Objs::Container.new @engine
    s = Gloo::Objs::String.new @engine
    s.name = 'one'
    o.add_child s
    assert_equal 1, o.child_count

    s = Gloo::Objs::String.new @engine
    s.name = 'two'
    o.add_child s
    assert_equal 2, o.child_count

    o.delete_children
    assert_equal 0, o.child_count
  end

  def test_remove_child
    o = Gloo::Core::Obj.new @engine
    s = Gloo::Objs::String.new @engine
    s.name = 'str'
    o.add_child s
    assert_equal 1, o.child_count
    o.remove_child s
    assert_equal 0, o.child_count
  end

  def test_find_nonexistant_child
    o = Gloo::Objs::Container.new @engine
    refute o.find_child( 'xtr' )
    s = Gloo::Objs::String.new @engine
    s.name = 'str'
    o.add_child s
    assert_same s, o.find_child( 'str' )
    refute o.find_child( 'xtr' )
    refute o.find_child( 'stri' )
    refute o.find_child( 'st' )
  end

  def test_child_count
    o = Gloo::Core::Obj.new @engine
    assert_equal 0, o.child_count
    o = Gloo::Objs::Container.new @engine
    assert_equal 0, o.child_count
    s = Gloo::Objs::String.new @engine
    s.name = 'str'
    o.add_child s
    assert_equal 1, o.child_count
  end

  def test_type_display
    o = Gloo::Objs::Container.new @engine
    assert_equal 'container', o.type_display
    s = Gloo::Objs::String.new @engine
    assert_equal 'string', s.type_display
  end

  def test_value_display
    s = Gloo::Objs::String.new @engine
    s.value = 'test'
    assert_equal 'test', s.value_display
  end

  def test_messages
    msgs = Gloo::Core::Obj.messages
    assert msgs
    assert msgs.include?( 'unload' )
  end

  def test_can_receive_message
    o = Gloo::Core::Obj.new @engine
    assert o.can_receive_message? 'unload'
    refute o.can_receive_message? 'xyz'
    refute o.can_receive_message? '123'
  end

  def test_sending_message
    o = @engine.factory.create( { :name => 's', :type => 'string' } )
    refute o.send_message( 'xyz' )
    refute o.send_message( 'abc' )
    assert o.send_message( 'unload' )
  end

  def test_dispatch
    o = @engine.factory.create( { :name => 's', :type => 'string' } )
    refute o.dispatch 'xyz'
    refute o.dispatch 'abc'
    assert o.dispatch 'unload'
  end

  def test_doesnt_add_children_on_create
    o = Gloo::Core::Obj.new @engine
    refute o.add_children_on_create?
  end

  def test_is_root_object
    o = @engine.factory.create( { :name => 's', :type => 'string' } )
    refute o.root?
    r = @engine.heap.root
    assert r
    assert r.root?
  end

  def test_object_can_be_created_by_default
    assert Gloo::Core::Obj.can_create?
  end

  def test_getting_pn_for_obj
    o = @engine.parser.parse_immediate "create can as can"
    o.run
    j = @engine.heap.root.children.first
    assert_equal 'can', j.pn

    o = @engine.parser.parse_immediate "create can.one as can"
    o.run
    j = j.children.first
    assert_equal 'can.one', j.pn

    o = @engine.parser.parse_immediate "create can.one.two as can"
    o.run
    j = j.children.first
    assert_equal 'can.one.two', j.pn
  end

  def test_display_value
    @engine.parser.run "create can as can"
    j = @engine.heap.root.children.first
    assert_equal 'can', j.display_value
  end

  def test_find_add_child
    o = Gloo::Objs::Container.new @engine
    assert 0, o.child_count
    child = o.find_add_child( 's', 'string' )
    assert child
    assert 1, o.child_count

    c2 = o.find_add_child( 's', 'string' )
    assert c2
    assert 1, o.child_count
    assert_same child, c2
  end

  def test_telling_an_object_to_unload
    @engine.parser.run 'load test'
    @engine.parser.run 'files'
    assert_equal 1, @engine.heap.it.value
    assert_equal 1, @engine.heap.root.child_count

    @engine.parser.run 'tell test to unload'

    @engine.parser.run 'files'
    assert_equal 0, @engine.heap.it.value
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_telling_an_object_to_reload
    @engine.parser.run 'load test'
    @engine.parser.run 'files'
    assert_equal 1, @engine.heap.it.value
    assert_equal 1, @engine.heap.root.child_count

    @engine.parser.run 'tell test to reload'

    @engine.parser.run 'files'
    assert_equal 1, @engine.heap.it.value
    assert_equal 1, @engine.heap.root.child_count
  end

end
