require 'test_helper'

#
# Every command that acts on an object reports a missing one as an
# error, whether the missing part is the last element of the path or
# one partway along it.
#
class MissingTargetTest < BaseEngineTest

  COMMANDS = [
    'tell %s to up',
    'check %s for blank?',
    'run %s',
    'invoke %s',
    'put 1 into %s',
    'list %s',
    'move %s to c',
    'move c.s to %s',
    'save %s',
    'redirect %s',
    'show %s'
  ].freeze

  def setup
    super
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.s as string : "hello"'
  end

  def test_missing_last_element_is_an_error
    COMMANDS.each { |cmd| assert_reported cmd % 'c.nope' }
  end

  def test_missing_middle_element_is_an_error
    COMMANDS.each { |cmd| assert_reported cmd % 'nope.deep.x' }
  end

  private

  def assert_reported( cmd )
    @engine.heap.error.clear
    @engine.parser.run cmd
    assert @engine.error?, "expected '#{cmd}' to report an error"
  end

end
