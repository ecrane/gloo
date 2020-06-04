require 'test_helper'

class SlackTest < Minitest::Test

  def setup
    @engine = Gloo::App::Engine.new( [ '--quiet' ] )
    @engine.start
    @dic = @engine.dictionary
  end

  def test_the_typename
    assert_equal 'slack', Gloo::Objs::Slack.typename
  end

  def test_the_short_typename
    assert_equal 'slack', Gloo::Objs::Slack.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'slack' )
    assert @dic.find_obj( 'SLACK' )
  end

  def test_messages
    msgs = Gloo::Objs::Slack.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Slack.new
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create s as slack'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 's', obj.name
    assert_equal 5, obj.child_count
    assert_equal 'uri', obj.children.first.name
    assert_equal 'message', obj.children[1].name
    assert_equal 'icon_emoji', obj.children.last.name
  end

  def test_help_text
    assert Gloo::Objs::Slack.help.start_with? 'SLACK OBJECT TYPE'
  end

end
