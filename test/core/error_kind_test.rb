require 'test_helper'

#
# Each error is either a syntax error (the command couldn't be
# understood: an unknown verb, or a required part is missing) or a
# runtime error (it was understood, but couldn't be done).
#
class ErrorKindTest < BaseEngineTest

  SYNTAX_ERRORS = [
    'nosuchverb',
    'invoke',
    'create x as gloo',
    'tell j to parse',
    'tell s to index_of',
    'if',
    'unless',
    'execute',
    'run',
    'redirect',
    'put',
    'put 1',
    'tell s to',
    'check s for',
    'load',
    'load a b c',
    'load nosuchopt x',
    'move',
    'move s',
    'create',
    'save s to',
    'exists?',
    'show "unclosed',
    'show 1 +',
    'create x as nosuchtype'
  ].freeze

  RUNTIME_ERRORS = [
    'show no.such.obj',
    'tell no.such.obj to up',
    'tell s to nosuchmsg',
    'put 1 into no.such.obj',
    'create no.such.x as int',
    "tell s to index_of ('l' 99)"
  ].freeze

  def setup
    super
    @engine.parser.run 'create s as string : "hello"'
    @engine.parser.run 'create j as json'
  end

  def test_syntax_errors
    SYNTAX_ERRORS.each { |cmd| assert_kind Gloo::Core::Error::SYNTAX, cmd }
  end

  def test_runtime_errors
    RUNTIME_ERRORS.each { |cmd| assert_kind Gloo::Core::Error::RUNTIME, cmd }
  end

  private

  def assert_kind( kind, cmd )
    @engine.heap.error.clear
    @engine.parser.run cmd
    assert @engine.error?, "expected '#{cmd}' to report an error"
    assert_equal kind, @engine.heap.error.kind,
      "expected '#{cmd}' to be a #{kind} error: #{@engine.heap.error.value}"
  end

  def test_unbalanced_paren_is_a_syntax_error
    # Run as a command, '(1' is then also read as a (missing) object name,
    # so check the verb's own syntax report.
    verb = @engine.parser.parse_immediate 'show (1'
    verb.check_syntax
    assert_equal Gloo::Core::Tokens::UNCLOSED_PAREN_ERR, @engine.heap.error.value
    assert_equal Gloo::Core::Error::SYNTAX, @engine.heap.error.kind
  end

end
