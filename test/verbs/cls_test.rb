require 'test_helper'

class ClsTest < BaseEngineTest

  def test_the_keyword
    o = Gloo::Verbs::Cls.keyword
    assert_equal 'clear', o
  end

  def test_the_keyword_shortcut
    assert_equal 'cls', Gloo::Verbs::Cls.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Cls.doc_data
    assert_equal Gloo::Verbs::Cls.keyword, data[:name]
    assert_equal Gloo::Verbs::Cls.keyword_shortcut, data[:shortcut]
  end

  #
  # Count screen clears instead of clearing the terminal mid-run.
  #
  def setup
    super
    @clears = 0
    clears = -> { @clears += 1 }
    @engine.platform.define_singleton_method( :clear_screen ) { clears.call }
  end

  def test_extra_words_warn_and_still_run
    warnings = capture_warnings { @engine.parser.run 'cls screen' }
    assert_equal 1, warnings.size
    assert_includes warnings.first, "cls takes no object; ignoring 'screen'."
    assert_equal 1, @clears
    refute @engine.error?
  end

  def test_bare_verb_does_not_warn
    warnings = capture_warnings { @engine.parser.run 'cls' }
    assert_empty warnings
    assert_equal 1, @clears
  end

  def test_warning_names_the_verb_as_written
    warnings = capture_warnings { @engine.parser.run 'clear screen' }
    assert_includes warnings.first, "clear takes no object; ignoring 'screen'."
  end

end
