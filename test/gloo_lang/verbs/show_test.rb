require 'test_helper'

class ShowTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'show', GlooLang::Verbs::Show.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '=', GlooLang::Verbs::Show.keyword_shortcut
  end

  def test_showing_a_string_literal
    v = @engine.parser.parse_immediate 'show "me"'
    v.run
    assert_equal 'me', @engine.heap.it.value
  end

  def test_showing_with_string_concat
    v = @engine.parser.parse_immediate 'show "me" "too"'
    v.run
    assert_equal 'metoo', @engine.heap.it.value
  end

  def test_showing_with_some_math
    v = @engine.parser.parse_immediate 'show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_showing_with_some_math_three_factor
    v = @engine.parser.parse_immediate 'show 3 + 9 + 1'
    v.run
    assert_equal 13, @engine.heap.it.value
  end

  def test_showing_an_object_value
    v = @engine.parser.parse_immediate 'create x : "boo"'
    v.run
    v = @engine.parser.parse_immediate 'show x'
    v.run
    assert_equal 'boo', @engine.heap.it.value
  end

end
