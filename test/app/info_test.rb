require 'test_helper'
require 'gloo-lang'

class InfoTest < Minitest::Test

  def test_version_number
    refute_nil Gloo::App::Info::VERSION
  end

  def test_app_name
    refute_nil Gloo::App::Info::APP_NAME
  end

  def test_the_display_name
    t = Gloo::App::Info.display_title
    assert t
    assert t.start_with? 'Gloo'
    assert t.end_with? Gloo::App::Info::VERSION
  end

  def test_the_full_version
    t = Gloo::App::Info.full_version
    assert t
    assert t.start_with? 'Gloo'
    assert t.end_with? GlooLang::App::Info.display_title
  end

end
