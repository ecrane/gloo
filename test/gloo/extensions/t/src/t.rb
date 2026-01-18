#
# A simple test verb.
# Puts 't' into it.
#
class T < Gloo::Core::Verb

  KEYWORD = 't'.freeze
  KEYWORD_SHORT = 't'.freeze

  #
  # Get the Verb's keyword.
  #
  def self.keyword
    return KEYWORD
  end

  #
  # Get the Verb's keyword shortcut.
  #
  def self.keyword_shortcut
    return KEYWORD_SHORT
  end

  #
  # Run the verb.
  #
  # We'll mark the application as not running and let the
  # engine stop gracefully next time through the loop.
  #
  def run
    @engine.heap.it.set_to 't'
  end

end
