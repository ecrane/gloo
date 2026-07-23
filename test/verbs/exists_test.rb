require 'test_helper'

class ExistsTest < BaseEngineTest

  def test_the_keyword
    o = Gloo::Verbs::Exists.keyword
    assert_equal 'exists?', o
  end

  def test_the_keyword_shortcut
    assert_equal 'exist', Gloo::Verbs::Exists.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Exists.doc_data
    assert_equal Gloo::Verbs::Exists.keyword, data[:name]
    assert_equal Gloo::Verbs::Exists.keyword_shortcut, data[:shortcut]
  end

  def test_exists_object
    @engine.parser.run 'exists? object string'
    assert @engine.heap.it.value

    @engine.parser.run 'exists? any string'
    assert @engine.heap.it.value

    @engine.parser.run 'exists? any asfasf'
    refute @engine.heap.it.value

    @engine.parser.run 'exists? string asfasf'
    refute @engine.heap.it.value

    @engine.parser.run 'exists? string'
    assert @engine.heap.it.value

    @engine.parser.run 'exists? can'
    assert @engine.heap.it.value

    @engine.parser.run 'exist can'
    assert @engine.heap.it.value

    @engine.parser.run 'exist asdfasdf'
    refute @engine.heap.it.value
  end

  def test_exists_verb
    @engine.parser.run 'exists? verb show'
    assert @engine.heap.it.value

    @engine.parser.run 'exists? verb asfasf'
    refute @engine.heap.it.value

    @engine.parser.run 'exists? 23af23'
    refute @engine.heap.it.value

    @engine.parser.run 'exist verb tell'
    assert @engine.heap.it.value

    @engine.parser.run 'exist verb show'
    assert @engine.heap.it.value

    @engine.parser.run 'exists? if'
    assert @engine.heap.it.value

    @engine.parser.run 'exists? unless'
    assert @engine.heap.it.value

    @engine.parser.run 'exist @'
    assert @engine.heap.it.value

    @engine.parser.run 'exist .'
    assert @engine.heap.it.value
  end

end
