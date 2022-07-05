require 'test_helper'

class GitTest < BaseEngineTest

  def test_the_typename
    assert_equal 'git_repo', Gloo::Objs::Git.typename
  end

  def test_the_short_typename
    assert_equal 'git', Gloo::Objs::Git.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'git_repo' )
    assert @dic.find_obj( 'git' )
  end

  def test_messages
    msgs = Gloo::Objs::Git.messages
    assert msgs
    assert msgs.include?( 'validate' )
    assert msgs.include?( 'check_changes' )
    assert msgs.include?( 'get_changes' )
    assert msgs.include?( 'review' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Git.new( @engine )
    refute o.add_children_on_create?
  end

end
