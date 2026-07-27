require 'test_helper'

class StringTest < BaseEngineTest

  def test_the_typename
    assert_equal 'string', Gloo::Objs::String.typename
  end

  def test_the_short_typename
    assert_equal 'str', Gloo::Objs::String.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::String.doc_data
    assert_equal Gloo::Objs::String.typename, data[:name]
    assert_equal Gloo::Objs::String.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'string' )
    assert @dic.find_obj( 'string' )
    assert @dic.find_obj( 'str' )
    assert @dic.find_obj( 'str' )
  end

  def test_setting_the_value
    o = Gloo::Objs::String.new @engine
    o.set_value( 'a string' )
    assert_equal 'a string', o.value
    o.set_value( 3 )
    assert_equal '3', o.value
    o.set_value( '177' )
    assert_equal '177', o.value
    o.set_value( ' 1 ' )
    assert_equal ' 1 ', o.value
    o.set_value( -13 )
    assert_equal '-13', o.value
  end

  def test_messages
    msgs = Gloo::Objs::String.messages
    assert msgs
    assert msgs.include?( 'starts_with?' )
    assert msgs.include?( 'ends_with?' )
    assert msgs.include?( 'substring?' )

    assert msgs.include?( 'up' )
    assert msgs.include?( 'down' )
    assert msgs.include?( 'unload' )

    assert msgs.include?( 'gen_alphanumeric' )
    assert msgs.include?( 'gen_uuid' )
    assert msgs.include?( 'gen_hex' )
    assert msgs.include?( 'gen_base64' )

    assert msgs.include?( 'encode64' )
    assert msgs.include?( 'decode64' )
  end

  def test_size_msg
    o = Gloo::Objs::String.new @engine
    o.set_value 'one'
    assert_equal 3, o.msg_size
  end

  def test_starts_with_msg
    o = @engine.parser.parse_immediate 'create s as string : "abc"'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    s = @engine.heap.root.children.first
    assert_equal 'abc', s.value

    o = @engine.parser.parse_immediate "check s for starts_with? ('a')"
    o.run
    assert @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for starts_with? ('ab')"
    o.run
    assert @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for starts_with? ('abc')"
    o.run
    assert @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for starts_with? ('x')"
    o.run
    refute @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for starts_with? ('abcd')"
    o.run
    refute @engine.heap.it.value
  end

  def test_ends_with_msg
    o = @engine.parser.parse_immediate 'create s as string : "abc"'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    s = @engine.heap.root.children.first
    assert_equal 'abc', s.value

    o = @engine.parser.parse_immediate "check s for ends_with? ('c')"
    o.run
    assert @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for ends_with? ('abc')"
    o.run
    assert @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for ends_with? ('abcd')"
    o.run
    refute @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for ends_with? ('b')"
    o.run
    refute @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for ends_with? ('bc')"
    o.run
    assert @engine.heap.it.value
  end

  def test_contains_msg
    o = @engine.parser.parse_immediate 'create s as string : "abc"'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    s = @engine.heap.root.children.first
    assert_equal 'abc', s.value

    o = @engine.parser.parse_immediate "check s for substring? ('bc')"
    o.run
    assert @engine.heap.it.value

    o = @engine.parser.parse_immediate "check s for substring? ('abcd')"
    o.run
    refute @engine.heap.it.value
  end

  def test_up_msg
    o = Gloo::Objs::String.new @engine
    o.set_value 'test'
    assert_equal 'TEST', o.msg_up
    assert_equal 'TEST', @engine.heap.it.value
  end

  def test_down_msg
    o = Gloo::Objs::String.new @engine
    o.set_value 'test'
    assert_equal 'test', o.msg_down
    assert_equal 'test', @engine.heap.it.value
  end

  def test_page_msg
    o = Gloo::Objs::String.new @engine
    o.set_value 'test'
    out, _err = capture_io do
      o.msg_page
    end
    assert_match 'test', out
  end

  def test_string_encoding_base64
    orig_value = 'Many hands make light work.'
    o = Gloo::Objs::String.new @engine
    o.set_value orig_value
    assert_equal orig_value, o.value

    o.msg_encode64
    refute_equal orig_value, o.value

    o.msg_decode64
    assert_equal orig_value, o.value
  end

  def test_string_url_escape
    orig_value = 'http://my.site.come/this is \a test?name=John Doe'
    o = Gloo::Objs::String.new @engine
    o.set_value orig_value
    assert_equal orig_value, o.value

    o.msg_escape
    refute_equal orig_value, o.value
    
    o.msg_unescape
    assert_equal orig_value, o.value
  end

  def test_trim_msg
    o = Gloo::Objs::String.new @engine
    o.set_value '  hello  '
    assert_equal 'hello', o.msg_trim
    assert_equal 'hello', o.value
    assert_equal 'hello', @engine.heap.it.value
  end

  def test_sub_msg
    o = @engine.parser.parse_immediate 'create s as string : "hello world"'
    o.run
    s = @engine.heap.root.children.first
    o = @engine.parser.parse_immediate "check s for sub ('world' 'gloo')"
    o.run
    assert_equal 'hello gloo', @engine.heap.it.value
  end

  def test_gsub_msg
    o = @engine.parser.parse_immediate 'create s as string : "aabbaa"'
    o.run
    s = @engine.heap.root.children.first
    o = @engine.parser.parse_immediate "check s for gsub ('a' 'x')"
    o.run
    assert_equal 'xxbbxx', @engine.heap.it.value
  end

  def test_count_chars_msg
    o = Gloo::Objs::String.new @engine
    o.set_value 'hello'
    assert_equal 5, o.msg_count_chars
  end

  def test_count_words_msg
    o = Gloo::Objs::String.new @engine
    o.set_value 'one two three'
    assert_equal 3, o.msg_count_words
  end

  def test_count_lines_msg
    o = Gloo::Objs::String.new @engine
    o.set_value "line one\nline two\nline three"
    assert_equal 3, o.msg_count_lines
  end

  def test_that_it_not_is_a_container
    o = Gloo::Objs::String.new @engine
    refute o.is_container?
  end
end
