require 'test_helper'
require 'tmpdir'

class ExecuteTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'execute', Gloo::Verbs::Execute.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'exec', Gloo::Verbs::Execute.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Execute.doc_data
    assert_equal Gloo::Verbs::Execute.keyword, data[:name]
    assert_equal Gloo::Verbs::Execute.keyword_shortcut, data[:shortcut]
  end

  def test_without_expression
    @engine.parser.run 'execute'
    assert @engine.error?
    assert_equal Gloo::Verbs::Execute::MISSING_EXPR_ERR, @engine.heap.error.value
  end

  def test_runs_the_evaluated_command
    path = File.join( Dir.tmpdir, "gloo_execute_test_#{Process.pid}" )
    File.delete( path ) if File.exist?( path )

    # the command is built from an object, so this also exercises
    # expression evaluation, not just a literal
    @engine.parser.run %(create cmd as string : "touch #{path}")
    v = @engine.parser.parse_immediate 'execute cmd'
    v.run

    assert File.exist?( path ), 'expected execute to run the evaluated command'
    refute @engine.error?
  ensure
    File.delete( path ) if path && File.exist?( path )
  end

end
