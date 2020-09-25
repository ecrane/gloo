require 'test_helper'

class ColorizeTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
    @dic = @engine.dictionary
  end

  def test_the_typename
    assert_equal 'colorize', Gloo::Objs::Colorize.typename
  end

  def test_the_short_typename
    assert_equal 'color', Gloo::Objs::Colorize.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'colorize' )
    assert @dic.find_obj( 'color' )
  end

  def test_messages
    msgs = Gloo::Objs::Colorize.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Colorize.new
    assert o.add_children_on_create?
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Objs::Colorize.typename
  end

end
