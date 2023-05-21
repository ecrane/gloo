require 'test_helper'

class SettingsTest < BaseEngineTest

  def test_creation
    s = Gloo::App::Settings.new( @engine )
    assert s
    assert s.user_root
    assert s.log_path
    assert s.config_path
    assert s.project_path
  end

  def test_engine_settings
    assert @engine.settings
    assert @engine.settings.user_root
    assert @engine.settings.log_path
    assert @engine.settings.config_path
    assert @engine.settings.project_path
  end


  def test_lines
    o = Gloo::App::Settings.lines( @engine )
    assert o
    assert( o > 1 )
    assert( o < 99_999_999 )
  end

  def test_cols
    o = Gloo::App::Settings.cols( @engine )
    assert o
    assert( o > 1 )
    assert( o < 99_999 )
  end

  def test_page_size
    o = Gloo::App::Settings.page_size( @engine )
    assert o
    assert( o > 1 )
    assert( o < 999 )
  end

  def test_debug_not_on_for_test
    refute @engine.settings.debug
  end
  
end
