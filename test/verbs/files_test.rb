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

  def test_extra_words_warn_and_still_run

    warnings = capture_warnings { @engine.parser.run 'files all' }
    assert_equal 1, warnings.size
    assert_includes warnings.first, "files takes no object; ignoring 'all'."
    refute @engine.error?
  end

  def test_bare_verb_does_not_warn
    warnings = capture_warnings { @engine.parser.run 'files' }
    assert_empty warnings
  end

end
