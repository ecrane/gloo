require 'test_helper'

class VersionTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'version', GlooLang::Verbs::Version.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'v', GlooLang::Verbs::Version.keyword_shortcut
  end

  def test_showing_version_info
    @engine.parser.run 'v'
    refute @engine.error?
  end

end
