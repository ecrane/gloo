require 'test_helper'

class FunctionTest < BaseEngineTest

  def test_the_typename
    assert_equal 'function', Gloo::Objs::Function.typename
  end

  def test_the_short_typename
    assert_equal 'ƒ', Gloo::Objs::Function.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Function.doc_data
    assert_equal Gloo::Objs::Function.typename, data[:name]
    assert_equal Gloo::Objs::Function.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'function' )
    assert @dic.find_obj( 'FUNCTION' )
    assert @dic.find_obj( 'ƒ' )
  end

  def test_messages
    msgs = Gloo::Objs::Function.messages
    assert msgs
    assert msgs.include?( 'invoke' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Function.new @engine
    assert o.add_children_on_create?
  end

  def test_creating_function_object
    o = @engine.parser.parse_immediate "create f as ƒ"
    o.run

    func = @engine.heap.root.children.first
    assert func
    assert func.children.count.positive?

    params = func.children.first
    assert params
    assert_equal 'params', params.name
  end

  def test_params_hash
    o = @engine.parser.parse_immediate "create f as ƒ"
    o.run
    func = @engine.heap.root.children.first

    h = func.params_hash
    assert h
    assert h.is_a?( Hash )
  end

  def test_result
    o = @engine.parser.parse_immediate "create f as ƒ"
    o.run
    func = @engine.heap.root.children.first

    result = func.result
    assert_equal '', result
  end

  def test_invoke_sets_it_on_success
    @engine.parser.run 'load ctrl/invoke'
    func = @engine.heap.root.find_child 'f'

    result = func.invoke( [] )
    assert_equal 7, result
    assert_equal 7, @engine.heap.it.value
    refute @engine.error?
  end

  def test_invoke_does_not_set_it_on_failure
    @engine.parser.run 'load ctrl/invoke'
    @engine.heap.it.set_to 'unchanged'
    func = @engine.heap.root.find_child 'failing'

    result = func.invoke( [] )
    assert_nil result
    assert @engine.error?
    assert_equal 'unchanged', @engine.heap.it.value
  end

end
