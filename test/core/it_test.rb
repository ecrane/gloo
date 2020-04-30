require 'test_helper'

class ItTest < Minitest::Test
  
  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
  end

  def test_it_constrution
    o = Gloo::Core::It.new
    assert o
    refute o.value
  end
  
  def test_setting_it
    o = Gloo::Core::It.new
    o.set_to "something"
    assert_equal "something", o.value
  end

  def test_to_s
    o = Gloo::Core::It.new
    o.set_to "other"
    assert_equal "other", "#{o}"
  end

  def test_setting_it_in_heap
    @engine.heap.it.set_to "boo"
    assert_equal "boo", @engine.heap.it.to_s
    assert_equal "boo", @engine.heap.it.value
  end
  
  def test_that_by_default_it_is_nil
    refute @engine.heap.it.value
  end
  
  def test_it_after_show
    v = @engine.parser.parse_immediate 'show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  
end
