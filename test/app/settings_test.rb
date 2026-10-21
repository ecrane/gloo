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

  def test_list_docs_defaults_to_false_when_absent_from_settings_file
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
          theme: dark
      YML

      s = Gloo::App::Settings.new( @engine, user_root )
      assert_equal false, s.list_docs
    end
  end

  def test_list_docs_read_from_settings_file
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
          list_docs: true
          debug: false
          theme: dark
      YML

      s = Gloo::App::Settings.new( @engine, user_root )
      assert_equal true, s.list_docs
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

  def test_tmp_path_defaults_to_tmp_under_user_root
    assert_equal File.join( @engine.settings.user_root, 'tmp' ), @engine.settings.tmp_path
    assert File.directory?( @engine.settings.tmp_path )
  end

  def test_tmp_path_written_to_new_settings_file
    Dir.mktmpdir do |root|
      user_root = File.join( root, 'gloo' )
      s = Gloo::App::Settings.new( @engine, user_root )
      assert_equal File.join( user_root, 'tmp' ), s.tmp_path

      yml = File.join( s.config_path, 'gloo.yml' )
      assert_includes File.read( yml ), "tmp_path: #{s.tmp_path}"
    end
  end

  def test_tmp_path_read_from_settings_file
    Dir.mktmpdir do |root|
      custom = File.join( root, 'my_scratch' )
      s = settings_from_yml( root, "  tmp_path: #{custom}\n" )
      assert_equal custom, s.tmp_path
    end
  end

  def test_tmp_path_from_settings_file_is_created_if_missing
    Dir.mktmpdir do |root|
      custom = File.join( root, 'not_there_yet' )
      refute File.exist?( custom )
      settings_from_yml( root, "  tmp_path: #{custom}\n" )
      assert File.directory?( custom )
    end
  end

  def test_tmp_path_from_settings_file_expands_a_leading_tilde
    Dir.mktmpdir do |root|
      s = settings_from_yml( root, "  tmp_path: ~/gloo_tilde_test_xyz\n" )
      assert_equal File.join( Dir.home, 'gloo_tilde_test_xyz' ), s.tmp_path
    ensure
      FileUtils.remove_entry( File.join( Dir.home, 'gloo_tilde_test_xyz' ), true )
    end
  end

  def test_tmp_path_falls_back_to_default_when_blank
    Dir.mktmpdir do |root|
      s = settings_from_yml( root, "  tmp_path:\n" )
      assert_equal File.join( root, 'gloo', 'tmp' ), s.tmp_path
      assert File.directory?( s.tmp_path )
    end
  end

  def test_tmp_path_falls_back_to_default_when_absent
    Dir.mktmpdir do |root|
      s = settings_from_yml( root, '' )
      assert_equal File.join( root, 'gloo', 'tmp' ), s.tmp_path
    end
  end

  private

  #
  # Build Settings for a new user root (gloo, under root) whose
  # gloo.yml has the usual settings plus the given extra lines.
  #
  def settings_from_yml( root, extra )
    user_root = File.join( root, 'gloo' )
    config_path = File.join( user_root, 'config' )
    FileUtils.mkdir_p( config_path )
    File.write( File.join( config_path, 'gloo.yml' ), <<~YML + extra )
      gloo:
        project_path:
        start_with:
        list_indent: 2
        list_levels: 3
        debug: false
        theme: dark
    YML
    return Gloo::App::Settings.new( @engine, user_root )
  end

end
