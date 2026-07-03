require 'test_helper'
require 'tempfile'

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
    assert msgs.include?( 'append' )
    assert msgs.include?( 'page' )
    assert msgs.include?( 'show' )
    assert msgs.include?( 'open' )
    assert msgs.include?( 'find_match' )
    assert msgs.include?( 'exists?' )
    assert msgs.include?( 'is_file?' )
    assert msgs.include?( 'is_dir?' )
    assert msgs.include?( 'get_sha256' )
  end

  def test_append_to_file_without_trailing_newline
    tmp = Tempfile.new( [ 'gloo_test', '.txt' ] )
    tmp.write( 'existing content' )
    tmp.close

    i = @engine.parser.parse_immediate "create f as file : '#{tmp.path}'"
    i.run
    i = @engine.parser.parse_immediate "tell f to append ('new line')"
    i.run

    result = File.read( tmp.path )
    assert result.include?( "existing content" )
    assert result.include?( "new line" )
    # new line should be on its own line
    assert_match( /existing content\nnew line/, result )
  ensure
    tmp.unlink
  end

  def test_append_to_file_with_trailing_newline
    tmp = Tempfile.new( [ 'gloo_test', '.txt' ] )
    tmp.write( "existing content\n" )
    tmp.close

    i = @engine.parser.parse_immediate "create f as file : '#{tmp.path}'"
    i.run
    i = @engine.parser.parse_immediate "tell f to append ('new line')"
    i.run

    result = File.read( tmp.path )
    assert_match( /existing content\nnew line/, result )
    # no blank line between items
    refute_match( /existing content\n\nnew line/, result )
  ensure
    tmp.unlink
  end

  def test_adds_children_on_create
    o = Gloo::Objs::FileHandle.new( @engine )
    refute o.add_children_on_create?
  end

  def test_getting_file_name_when_blank
    i = @engine.parser.parse_immediate "create f as file"
    i.run
    obj = @engine.heap.root.children.first
    assert obj

    i = @engine.parser.parse_immediate 'check f for get_name'
    i.run
    assert_equal '', @engine.heap.it.value
  end

  def test_getting_file_ext_when_blank
    i = @engine.parser.parse_immediate "create f as file"
    i.run
    obj = @engine.heap.root.children.first
    assert obj

    i = @engine.parser.parse_immediate 'check f for get_ext'
    i.run
    assert_equal '', @engine.heap.it.value
  end

  def test_getting_file_parent_when_blank
    i = @engine.parser.parse_immediate "create f as file"
    i.run
    obj = @engine.heap.root.children.first
    assert obj

    i = @engine.parser.parse_immediate 'check f for get_parent'
    i.run
    assert_equal '', @engine.heap.it.value
  end

  def test_getting_file_name
    f = "/path/to/file.txt"
    i = @engine.parser.parse_immediate "create f as file : '#{f}'"
    i.run
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal f, obj.value

    i = @engine.parser.parse_immediate 'check f for get_name'
    i.run
    assert_equal 'file', @engine.heap.it.value
  end

  def test_getting_file_ext
    f = "/path/to/file.txt"
    i = @engine.parser.parse_immediate "create f as file : '#{f}'"
    i.run
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal f, obj.value

    i = @engine.parser.parse_immediate 'check f for get_ext'
    i.run
    assert_equal '.txt', @engine.heap.it.value
  end

  def test_getting_file_parent
    f = "/path/to/file.txt"
    i = @engine.parser.parse_immediate "create f as file : '#{f}'"
    i.run
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal f, obj.value

    i = @engine.parser.parse_immediate 'check f for get_parent'
    i.run
    assert_equal '/path/to', @engine.heap.it.value
  end

  def test_write_and_read
    tmp = Tempfile.new( [ 'gloo_test', '.txt' ] )
    tmp.close

    i = @engine.parser.parse_immediate "create f as file : '#{tmp.path}'"
    i.run
    i = @engine.parser.parse_immediate "tell f to write ('hello world')"
    i.run

    assert_equal 'hello world', File.read( tmp.path )

    i = @engine.parser.parse_immediate 'tell f to read'
    i.run
    assert_equal 'hello world', @engine.heap.it.value
  ensure
    tmp.unlink
  end

  def test_exists_msg
    tmp = Tempfile.new( [ 'gloo_test', '.txt' ] )
    tmp.close

    i = @engine.parser.parse_immediate "create f as file : '#{tmp.path}'"
    i.run
    i = @engine.parser.parse_immediate 'check f for exists?'
    i.run
    assert @engine.heap.it.value

    tmp.unlink
    i = @engine.parser.parse_immediate 'check f for exists?'
    i.run
    refute @engine.heap.it.value
  end

end
