require 'test_helper'

class IntegerTest < BaseEngineTest

  def test_the_typename
    assert_equal 'integer', Gloo::Objs::Integer.typename
  end

  def test_the_short_typename
    assert_equal 'int', Gloo::Objs::Integer.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Integer.doc_data
    assert_equal Gloo::Objs::Integer.typename, data[:name]
    assert_equal Gloo::Objs::Integer.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'integer' )
    assert @dic.find_obj( 'INTEGER' )
    assert @dic.find_obj( 'int' )
    assert @dic.find_obj( 'INT' )
  end

  def test_setting_the_value
    o = Gloo::Objs::Integer.new @engine
    o.set_value( 3 )
    assert_equal 3, o.value
    o.set_value( '177' )
    assert_equal 177, o.value
    o.set_value( ' 1 ' )
    assert_equal 1, o.value
    o.set_value( -13 )
    assert_equal( -13, o.value )
  end

  def test_messages
    msgs = Gloo::Objs::Integer.messages
    assert msgs
    assert msgs.include?( 'inc' )
    assert msgs.include?( 'dec' )
    assert msgs.include?( 'unload' )
    assert msgs.include?( 'randomize' )
    assert msgs.include?( 'format' )
  end

  def test_inc_msg
    o = Gloo::Objs::Integer.new @engine
    o.set_value 0
    assert_equal 0, o.value
    assert_equal 1, o.msg_inc
    assert_equal 1, o.value
    assert_equal 1, @engine.heap.it.value
  end

  def test_dec_msg
    o = Gloo::Objs::Integer.new @engine
    o.set_value 0
    assert_equal 0, o.value
    assert_equal( -1, o.msg_dec )
    assert_equal( -1, o.value )
    assert_equal( -1, @engine.heap.it.value )
  end

  def test_randomize_msg
    o = Gloo::Objs::Integer.new @engine
    o.set_value 0
    assert_equal 0, o.value

    10.times do
      rand_val = o.msg_randomize
      assert( rand_val >= 0 )
      assert( rand_val < 100 )
    end
  end

  def test_randomize_msg_with_max
    i = @engine.parser.parse_immediate 'create i as int'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj

    10.times do
      i = @engine.parser.parse_immediate 'tell i to randomize(2)'
      i.run
      rand_val = obj.value
      assert ( ( rand_val == 0 ) || ( rand_val == 1 ) )
    end
  end

  def test_that_it_not_is_a_container
    o = Gloo::Objs::Integer.new @engine
    refute o.is_container?
  end

  def test_format_msg_default
    i = @engine.parser.parse_immediate 'create i as int'
    i.run
    i = @engine.parser.parse_immediate "put 1234567 into i"
    i.run

    i = @engine.parser.parse_immediate 'tell i to format'
    i.run
    assert_equal '1,234,567', @engine.heap.it.value
  end

  def test_format_msg_negative_default
    i = @engine.parser.parse_immediate 'create i as int'
    i.run
    i = @engine.parser.parse_immediate "put -1234567 into i"
    i.run

    i = @engine.parser.parse_immediate 'tell i to format'
    i.run
    assert_equal '-1,234,567', @engine.heap.it.value
  end

  def test_format_msg_with_format_string
    i = @engine.parser.parse_immediate 'create i as int'
    i.run
    i = @engine.parser.parse_immediate "put 42 into i"
    i.run

    i = @engine.parser.parse_immediate "tell i to format ('%05d')"
    i.run
    assert_equal '00042', @engine.heap.it.value
  end

end
