require 'test_helper'

class ItTest < BaseEngineTest

  def test_it_constrution
    o = GlooLang::Core::It.new
    assert o
    refute o.value
  end

  def test_setting_it
    o = GlooLang::Core::It.new
    o.set_to 'something'
    assert_equal 'something', o.value
  end

  def test_to_s
    o = GlooLang::Core::It.new
    o.set_to 'other'
    assert_equal 'other', o.to_s
  end

  def test_setting_it_in_heap
    @engine.heap.it.set_to 'boo'
    assert_equal 'boo', @engine.heap.it.to_s
    assert_equal 'boo', @engine.heap.it.value
  end

  def test_that_by_default_it_is_nil
    refute @engine.heap.it.value
  end

  def test_it_after_show
    v = @engine.parser.parse_immediate 'show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_show_it
    @engine.parser.run 'show 72 + 18'
    @engine.parser.run 'show it'
    assert_equal 90, @engine.heap.it.value
  end

end
