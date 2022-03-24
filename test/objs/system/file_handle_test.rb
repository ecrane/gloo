require 'test_helper'

class FileHandleTest < BaseEngineTest

  def test_the_typename
    assert_equal 'file', Gloo::Objs::FileHandle.typename
  end

  def test_the_short_typename
    assert_equal 'dir', Gloo::Objs::FileHandle.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'file' )
    assert @dic.find_obj( 'FILE' )
    assert @dic.find_obj( 'dir' )
  end

  def test_messages
    msgs = Gloo::Objs::FileHandle.messages
    assert msgs
    assert msgs.include?( 'read' )
    assert msgs.include?( 'write' )
    assert msgs.include?( 'page' )
    assert msgs.include?( 'show' )
    assert msgs.include?( 'open' )
    assert msgs.include?( 'find_match' )
    assert msgs.include?( 'check_exists' )
    assert msgs.include?( 'check_is_file' )
    assert msgs.include?( 'check_is_dir' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::FileHandle.new( @engine )
    refute o.add_children_on_create?
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Objs::FileHandle.typename
  end

end
