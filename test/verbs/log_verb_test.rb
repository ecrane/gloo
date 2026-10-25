require 'test_helper'

class LogVerbTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'log', Gloo::Verbs::Log.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'log', Gloo::Verbs::Log.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Log.doc_data
    assert_equal Gloo::Verbs::Log.keyword, data[:name]
    assert_equal Gloo::Verbs::Log.keyword_shortcut, data[:shortcut]
  end

  def test_writing_to_log
    @engine.parser.run 'log "hello from log"'
    assert_equal 'hello from log', @engine.heap.it.value
  end

  def test_clearing_the_log
    @engine.parser.run 'log clear'
    refute @engine.error?
  end

  def test_logging_puts_the_value_in_it
    capture_logged { @engine.parser.run 'log 3 + 4' }
    assert_equal 7, @engine.heap.it.value
  end

  # ---------------------------------------------------------------------
  #    A failed expression: the partial value is logged, it is false
  # ---------------------------------------------------------------------

  def test_a_missing_object_puts_false_in_it
    @engine.heap.it.set_to 'before'
    capture_logged { @engine.parser.run 'log no_such_obj' }
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  def test_a_failure_part_way_still_logs_the_partial_value
    logged = capture_logged { @engine.parser.run 'log 1 + no_such_obj' }
    assert @engine.error?
    assert_equal [ [ 1, Gloo::App::Log::DEBUG ] ], logged
    assert_equal false, @engine.heap.it.value
  end

  # ---------------------------------------------------------------------
  #    A failed level: logged at the default level, the value goes in it
  # ---------------------------------------------------------------------

  def test_a_failed_level_logs_at_the_default_level
    logged = capture_logged { @engine.parser.run "log 'x' (no_such_obj)" }
    assert_equal [ [ 'x', Gloo::App::Log::DEBUG ] ], logged
  end

  def test_a_failed_level_puts_the_value_in_it
    capture_logged { @engine.parser.run "log 'x' (no_such_obj)" }
    assert @engine.error?
    assert_equal 'x', @engine.heap.it.value
  end

  private

  #
  # Run the block and return what the log verb wrote, as
  # [ message, level ] pairs.
  #
  def capture_logged
    logged = []
    @engine.log.define_singleton_method( :write ) { |msg, level| logged << [ msg, level ] }
    yield
    return logged
  ensure
    @engine.log.singleton_class.send( :remove_method, :write )
  end

end
