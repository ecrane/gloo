require 'test_helper'

class FileSaverTest < BaseEngineTest

  def test_getting_simple_object
    o = @engine.factory.create(
      { :name => 's', :type => 'str', :value => 'one' } )
    assert o

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    assert fs

    str = fs.get_obj o
    assert_equal "s [string] : one\n", str
  end

  def test_getting_a_container_with_children
    c = @engine.factory.create( { :name => 'c', :type => 'can' } )
    @engine.factory.create( { :name => 's', :type => 'str', :value => 'one',
                               :parent => c } )
    assert c

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    str = fs.get_obj c
    assert_equal "c [container] : \n\ts [string] : one\n", str
  end

  def test_getting_a_script_with_multiple_lines
    o = Gloo::Objs::Script.new @engine
    o.name = 's'
    o.set_array_value [ 'show 2 + 3', 'show 1 + 2' ]

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    str = fs.get_obj o
    assert_equal "s [script] :\n\tshow 2 + 3\n\tshow 1 + 2\n", str
  end

  def test_getting_a_multiline_string_value_as_begin_end_block
    o = @engine.factory.create(
      { :name => 't', :type => 'str', :value => "line one\nline two" } )

    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )
    str = fs.get_obj o
    assert_equal "t [string] : BEGIN\n\tline one\n\tline two\nEND\n", str
  end

  def test_tabs
    fs = Gloo::Persist::FileSaver.new( @engine, '', nil )

    assert_equal '', fs.tabs
    assert_equal '', fs.tabs( 0 )
    assert_equal "\t", fs.tabs( 1 )
    assert_equal "\t\t", fs.tabs( 2 )
  end

end
