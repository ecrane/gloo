require 'test_helper'

class RunTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
  end

  def test_the_keyword
    assert_equal 'run', Gloo::Verbs::Run.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'r', Gloo::Verbs::Run.keyword_shortcut
  end

  def test_running_script
    s = 'create s as script : "show 3 + 4"'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count
    @engine.parser.run 'run s'
    assert_equal 7, @engine.heap.it.value
  end

  def test_running_evaluated_string
    s = 'create s as string : "show 3 + 4"'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count
    @engine.parser.run 'run ~> s'
    assert_equal 7, @engine.heap.it.value
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Verbs::Run.keyword
  end

  def test_without_expression
    @engine.parser.run 'run'
    assert @engine.error?
    assert_equal Gloo::Verbs::Run::MISSING_EXPR_ERR, @engine.heap.error.value
  end

  def test_evaluated_without_expression
    @engine.parser.run 'run ~>'
    assert @engine.error?
    assert_equal Gloo::Verbs::Run::MISSING_EXPR_ERR, @engine.heap.error.value
  end

end
