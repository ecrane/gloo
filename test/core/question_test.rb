require 'test_helper'

#
# A question whose answer is "no" is a result, not an error: asking
# about something that doesn't exist never reports an error.
#
class QuestionTest < BaseEngineTest

  QUESTIONS = {
    'exists? instance c.nope' => false,
    'exists? instance nope.deep.x' => false,
    'exists? verb nosuchverb' => false,
    'exists? obj nosuchtype' => false,
    'tell ln* to resolve' => false,
    'check c.sub for contains?' => false,
    "check c.s for responds_to? ('nosuchmsg')" => false,
    "check c.s for starts_with? ('zz')" => false,
    "check c.s for ends_with? ('zz')" => false,
    "check c.s for substring? ('zz')" => false,
    "tell c.s to index_of ('zz')" => -1,
    'check f for exists?' => false
  }.freeze

  def setup
    super
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.sub as can'
    @engine.parser.run 'create c.s as string : "hello"'
    @engine.parser.run 'create ln as alias : nope.deep.x'
    @engine.parser.run 'create f as file : "/no/such/file.txt"'
  end

  def test_no_answer_is_not_an_error
    QUESTIONS.each do |cmd, answer|
      @engine.heap.error.clear
      @engine.parser.run cmd
      refute @engine.error?, "expected '#{cmd}' to not report an error"
      assert_equal answer, @engine.heap.it.value, "expected '#{cmd}' to answer #{answer}"
    end
  end

end
