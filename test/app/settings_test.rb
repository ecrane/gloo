require 'test_helper'
require 'tmpdir'

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

  def test_theme_defaults_to_dark
    assert_equal 'dark', @engine.settings.theme
  end

  def test_theme_written_to_new_settings_file
    Dir.mktmpdir do |root|
      user_root = File.join( root, 'gloo' )
      s = Gloo::App::Settings.new( @engine, user_root )
      assert_equal 'dark', s.theme

      yml = File.join( s.config_path, 'gloo.yml' )
      assert_includes File.read( yml ), 'theme: dark'
    end
  end

  def test_theme_read_from_settings_file
    Dir.mktmpdir do |root|
      user_root = File.join( root, 'gloo' )
      Dir.mkdir( user_root )
      config_path = File.join( user_root, 'config' )
      Dir.mkdir( config_path )
      File.write( File.join( config_path, 'gloo.yml' ), <<~YML )
        gloo:
          project_path:
          start_with:
          list_indent: 2
          list_levels: 3
          debug: false
          theme: light
      YML

      s = Gloo::App::Settings.new( @engine, user_root )
      assert_equal 'light', s.theme
    end
  end

  def test_theme_falls_back_to_default_when_invalid
    Dir.mktmpdir do |root|
      user_root = File.join( root, 'gloo' )
      Dir.mkdir( user_root )
      config_path = File.join( user_root, 'config' )
      Dir.mkdir( config_path )
      File.write( File.join( config_path, 'gloo.yml' ), <<~YML )
        gloo:
          project_path:
          start_with:
          list_indent: 2
          list_levels: 3
          debug: false
          theme: purple
      YML

      s = Gloo::App::Settings.new( @engine, user_root )
      assert_equal 'dark', s.theme
    end
  end

end
