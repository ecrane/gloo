require 'test_helper'

class FilesTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'files', Gloo::Verbs::Files.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'fs', Gloo::Verbs::Files.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Files.doc_data
    assert_equal Gloo::Verbs::Files.keyword, data[:name]
    assert_equal Gloo::Verbs::Files.keyword_shortcut, data[:shortcut]
  end

  def test_showing_files
    @engine.parser.run 'load test'
    @engine.parser.run 'files'
    assert_equal 1, @engine.heap.it.value
  end

end
