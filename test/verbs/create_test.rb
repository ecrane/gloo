require "test_helper"

class CreateTest < Minitest::Test
  
  def setup
    @engine = OutlineScript::App::Engine.new( [ "--quiet" ] )
    @engine.start
  end

  def test_the_keyword
    assert_equal "create", OutlineScript::Verbs::Create.keyword
  end

  def test_the_keyword_shortcut
    assert_equal "`", OutlineScript::Verbs::Create.keyword_shortcut
  end

  def test_object_creation_default_type
    i = @engine.parser.parse_immediate '` x : 1'
    i.run
    assert_equal "1", @engine.heap.it.value
  end

  def test_object_creation_integer
    i = @engine.parser.parse_immediate '` x as integer : 1'
    i.run
    i = @engine.parser.parse_immediate '= x'
    i.run
    assert_equal 1, @engine.heap.it.value
  end

end
