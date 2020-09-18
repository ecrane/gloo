require 'test_helper'

class CreateTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
  end

  def test_the_keyword
    assert_equal 'create', Gloo::Verbs::Create.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '`', Gloo::Verbs::Create.keyword_shortcut
  end

  def test_object_creation_default_type
    i = @engine.parser.parse_immediate '` x : 1'
    i.run
    assert_equal '1', @engine.heap.it.value
  end

  def test_object_creation_integer
    i = @engine.parser.parse_immediate '` x as integer : 1'
    i.run
    i = @engine.parser.parse_immediate '= x'
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

  def test_help_text
    assert @engine.help.topic? Gloo::Verbs::Create.keyword
  end

end
