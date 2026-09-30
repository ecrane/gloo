require 'test_helper'

class SystemTest < BaseEngineTest

  def test_the_typename
    assert_equal 'system', Gloo::Objs::System.typename
  end

  def test_the_short_typename
    assert_equal 'sys', Gloo::Objs::System.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::System.doc_data
    assert_equal Gloo::Objs::System.typename, data[:name]
    assert_equal Gloo::Objs::System.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'sys' )
    assert @dic.find_obj( 'SYSTEM' )
    assert @dic.find_obj( 'system' )
  end

  def test_messages
    msgs = Gloo::Objs::System.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::System.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create s as sys'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 's', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'command', obj.children.first.name
    assert_equal 'get_output', obj.children[ 1 ].name
    assert_equal 'result', obj.children.last.name
  end

  def test_run_system
    i = @engine.parser.parse_immediate 'create s as sys'
    i.run
    obj = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate 'put "date" into s.command'
    i.run
    assert_equal '', obj.children.last.value

    i = @engine.parser.parse_immediate 'run s'
    i.run
    refute_equal '', obj.children.last.value
  end

  def test_run_with_output_sets_it
    @engine.parser.run 'create s as sys'
    @engine.parser.run 'put "echo hi" into s.command'
    @engine.parser.run 'run s'
    assert_equal "hi\n", @engine.heap.it.value
  end

  def test_run_without_output_sets_it_to_success
    @engine.parser.run 'create s as sys'
    @engine.parser.run 'put "true" into s.command'
    @engine.parser.run 'put false into s.get_output'
    @engine.parser.run 'run s'
    assert_equal true, @engine.heap.it.value
  end

  def test_run_of_an_unknown_command_is_an_error
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create s as sys'
    @engine.parser.run "put 'no_such_cmd_xyz' into s.command"
    @engine.parser.run 'run s'
    assert @engine.error?
    assert_includes @engine.heap.error.value.to_s, "Could not run 'no_such_cmd_xyz':"
    assert_equal false, @engine.heap.it.value
  end

end
