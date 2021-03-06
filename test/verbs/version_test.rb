require 'test_helper'

class VersionTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
  end

  def test_the_keyword
    assert_equal 'version', Gloo::Verbs::Version.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'v', Gloo::Verbs::Version.keyword_shortcut
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Verbs::Version.keyword
  end

end
