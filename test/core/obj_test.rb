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

  #
  # root? used to call name.downcase unconditionally, which raised
  # for any parentless object with a nil name (rather than the
  # default '' from Baseo). Confirm it degrades gracefully instead.
  #
  def test_root_check_does_not_raise_for_nil_name
    o = Gloo::Core::Obj.new @engine
    o.name = nil
    refute o.root?
  end

  #
  # Regression: pn used to return the literal string "root" when
  # called on root itself, which broke path resolution for anything
  # built on top of it (eg. Here.expand_here). Paths are root-relative,
  # so root has no path/name segment of its own.
  #
  def test_root_pn_is_empty
    assert_equal '', @engine.heap.root.pn
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

  def test_obj_is_alias_check
    o = Gloo::Objs::Container.new @engine
    assert o
    refute o.is_alias?

    o = Gloo::Objs::String.new @engine
    assert o
    refute o.is_alias?

    o = Gloo::Objs::Alias.new @engine
    assert o
    assert o.is_alias?
  end

  def test_obj_is_function_check
    o = Gloo::Objs::Container.new @engine
    assert o
    refute o.is_function?

    o = Gloo::Objs::String.new @engine
    assert o
    refute o.is_function?

    o = Gloo::Objs::Function.new @engine
    assert o
    assert o.is_function?
  end

  def test_check_for_blank
    o = @engine.parser.parse_immediate 'create s as string'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    o = @engine.parser.parse_immediate 'check s for blank?'
    o.run
    assert @engine.heap.it.value

    o = @engine.parser.parse_immediate "put 'x' into s"
    o.run

    o = @engine.parser.parse_immediate 'check s for blank?'
    o.run
    refute @engine.heap.it.value
  end

  def test_check_for_contains
    o = @engine.parser.parse_immediate 'create c as can'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    o = @engine.parser.parse_immediate 'check c for contains?'
    o.run
    refute @engine.heap.it.value

    o = @engine.parser.parse_immediate "create c.a as string"
    o.run

    o = @engine.parser.parse_immediate 'check c for contains?'
    o.run
    assert @engine.heap.it.value
  end

  def test_find_child_resolve_alias
    @engine.parser.run 'create s as string : hello'
    @engine.parser.run 'create a as alias : s'
    can = @engine.heap.root
    a = can.find_child( 'a' )
    resolved = can.find_child_resolve_alias( 'a' )
    assert resolved
    refute_same a, resolved
    assert_equal 'hello', resolved.value
  end

  def test_find_child_value
    @engine.parser.run 'create s as string : world'
    can = @engine.heap.root
    val = can.find_child_value( 's' )
    assert_equal 'world', val
    assert_nil can.find_child_value( 'nonexistent' )
  end

  def test_responds_to_message
    @engine.parser.run 'create s as string : test'
    @engine.parser.run "check s for responds_to? ('blank?')"
    assert @engine.heap.it.value

    @engine.parser.run "check s for responds_to? ('nosuchmsg')"
    refute @engine.heap.it.value
  end

end
