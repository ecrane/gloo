require 'test_helper'

class CreateTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'create', Gloo::Verbs::Create.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '`', Gloo::Verbs::Create.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Create.doc_data
    assert_equal Gloo::Verbs::Create.keyword, data[:name]
    assert_equal Gloo::Verbs::Create.keyword_shortcut, data[:shortcut]
  end

  def test_object_creation_default_type
    i = @engine.parser.parse_immediate '` x : 1'
    i.run
    assert_equal '1', @engine.heap.it.value
  end

  def test_object_creation_integer
    i = @engine.parser.parse_immediate '` x as integer : 1'
    i.run
    i = @engine.parser.parse_immediate 'show x'
    i.run
    assert_equal 1, @engine.heap.it.value
  end

  def test_object_creation
    @engine.parser.run 'create x as integer : 1'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 1, @engine.heap.root.children.first.value
  end

  def test_object_creation_without_name
    @engine.parser.run 'create'
    assert_equal 0, @engine.heap.root.child_count
    assert @engine.error?
    assert_equal Gloo::Verbs::Create::NO_NAME_ERR, @engine.heap.error.value
  end

  def test_object_creation_bad_path
    i = @engine.parser.parse_immediate '` x.y.z'
    i.run
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_object_creation_with_alias
    assert_equal 0, @engine.heap.root.child_count

    i = @engine.parser.parse_immediate '` ln as alias : x'
    i.run
    assert_equal 1, @engine.heap.root.child_count

    i = @engine.parser.parse_immediate 'create ln* as string : "hello"'
    i.run
    s = @engine.heap.root.children.last
    assert s
    refute s.is_alias?
    assert_equal s.value, 'hello'
  end

  def test_create_with_missing_parent_is_an_error
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create no.such.x as int : 1'
    assert @engine.error?
    assert_equal "Could not create 'no.such.x': Object 'no.such' was not found.",
      @engine.heap.error.value
    assert_equal 'before', @engine.heap.it.value
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_create_with_unknown_type_creates_it_untyped
    @engine.parser.run 'create x as nosuchtype : 3'
    assert @engine.error?
    assert_equal Gloo::Core::Error::SYNTAX, @engine.heap.error.kind
    x = @engine.heap.root.find_child( 'x' )
    assert_equal 'untyped', x.type_display
    assert_equal '3', x.value
  end

  def test_create_it_is_an_error
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run "eval 'abc'"
    @engine.parser.run "create it as string"
    assert @engine.error?
    assert_includes @engine.heap.error.value, "it isn't an object and can't be created;"
    assert_equal 'abc', @engine.heap.it.value
  end

  def test_create_with_no_name_sets_it_false
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

end
