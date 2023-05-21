require 'test_helper'

class GlooSystemTest < BaseEngineTest

  def test_the_typename
    assert_equal 'gloo', Gloo::Core::GlooSystem.typename
  end

  def test_the_short_typename
    assert_equal '$', Gloo::Core::GlooSystem.short_typename
  end

  def test_marked_as_cannot_be_created
    refute Gloo::Core::GlooSystem.can_create?
    assert Gloo::Objs::Script.can_create?
    assert Gloo::Objs::String.can_create?
  end

  def test_cannot_be_created
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'create s as gloo :'
    i.run
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'create s as $ :'
    i.run
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_param
    pn = Gloo::Core::Pn.new( @engine, '$.hostname' )
    o = Gloo::Core::GlooSystem.new( @engine, pn )
    assert o
    assert o.pn
    assert_equal 'hostname', o.param

    pn = Gloo::Core::Pn.new( @engine, '$.user.home' )
    o = Gloo::Core::GlooSystem.new( @engine, pn )
    assert o
    assert o.pn
    assert_equal 'user_home', o.param
  end

  def test_no_value
    i = @engine.parser.parse_immediate 'show $.asdfjasdfj'
    i.run
    assert_equal false, @engine.heap.it.value
  end

  def test_hostname
    i = @engine.parser.parse_immediate 'show $.hostname'
    i.run
    assert_equal Socket.gethostname, @engine.heap.it.value
  end

  def test_user
    i = @engine.parser.parse_immediate 'show $.user'
    i.run
    i = @engine.heap.it.value
    assert_equal ENV[ 'USER' ], i

    # same as this
    j = @engine.parser.parse_immediate 'show gloo.user'
    j.run
    j = @engine.heap.it.value
    assert_equal ENV[ 'USER' ], j
    assert_equal i, j
  end

  def test_gloo_home
    i = @engine.parser.parse_immediate 'show $.gloo.home'
    i.run
    i = @engine.heap.it.value
    assert_equal @engine.settings.user_root, i

    # same as this
    j = @engine.parser.parse_immediate 'show gloo.gloo_home'
    j.run
    j = @engine.heap.it.value
    assert_equal @engine.settings.user_root, j
    assert_equal i, j
  end

  def test_gloo_config
    i = @engine.parser.parse_immediate 'show $.gloo.config'
    i.run
    assert_equal @engine.settings.config_path, @engine.heap.it.value
  end

  def test_gloo_project_path
    i = @engine.parser.parse_immediate 'show $.gloo.projects'
    i.run
    assert_equal @engine.settings.project_path, @engine.heap.it.value
  end

  def test_gloo_log_path
    i = @engine.parser.parse_immediate 'show $.gloo.log'
    i.run
    assert_equal @engine.settings.log_path, @engine.heap.it.value
  end

  def test_screen_lines
    i = @engine.parser.parse_immediate 'show $.screen.lines'
    i.run
    assert_equal GlooLang::App::Settings.lines( @engine ), @engine.heap.it.value

    i = @engine.parser.parse_immediate 'show $.screen_lines'
    i.run
    assert_equal GlooLang::App::Settings.lines( @engine ), @engine.heap.it.value
  end

  def test_screen_cols
    i = @engine.parser.parse_immediate 'show $.screen.cols'
    i.run
    assert_equal GlooLang::App::Settings.cols( @engine ), @engine.heap.it.value

    i = @engine.parser.parse_immediate 'show $.screen_cols'
    i.run
    assert_equal GlooLang::App::Settings.cols( @engine ), @engine.heap.it.value
  end

  def test_line
    i = @engine.parser.parse_immediate 'show $.line'
    i.run
    assert_equal "\n", @engine.heap.it.value
  end

  def test_open_for_platform
    cmd = Gloo::Core::GlooSystem.open_for_platform
    assert_equal 'open', cmd
  end

end
