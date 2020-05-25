require 'test_helper'

class LoadTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
  end

  def test_the_keyword
    assert_equal 'load', Gloo::Verbs::Load.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '<', Gloo::Verbs::Load.keyword_shortcut
  end

  def test_file_load
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'load test'
    i.run
    assert_equal 1, @engine.heap.root.child_count
  end

  def test_file_load_multiline_script
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate '< script'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 5, @engine.heap.it.value
  end

  def test_help_text
    assert Gloo::Verbs::Load.help.start_with? 'LOAD VERB'
  end

end
