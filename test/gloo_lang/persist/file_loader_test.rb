require 'test_helper'

class FileLoaderTest < BaseEngineTest

  def test_splitting_a_line
    fs = GlooLang::Persist::FileLoader.new( @engine, '' )
    n, t, v = fs.split_line( "name type value\n" )
    assert_equal 'name', n
    assert_equal 'type', t
    assert_equal 'value', v

    n, t, v = fs.split_line( "name [type] one two three\n" )
    assert_equal 'name', n
    assert_equal 'type', t
    assert_equal 'one two three', v

    n, t, v = fs.split_line( 'my_string [str] : xyz' )
    assert_equal 'my_string', n
    assert_equal 'str', t
    assert_equal 'xyz', v
  end

  def test_tab_count
    fs = GlooLang::Persist::FileLoader.new( @engine, '' )

    assert_equal 0, fs.tab_count( 'one' )
    assert_equal 1, fs.tab_count( "\tone" )
    assert_equal 2, fs.tab_count( "\t\ttwo222" )
    assert_equal 3, fs.tab_count( "\t\t\tthree" )
    assert_equal 1, fs.tab_count( "  one" )
    assert_equal 2, fs.tab_count( "    two" )
    assert_equal 3, fs.tab_count( "      three" )
  end

  def test_loading_a_file
    assert_equal 0, @engine.heap.root.child_count
    @engine.persist_man.load 'test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name
  end

  def test_loading_a_file_that_doesnt_exist
    assert_equal 0, @engine.heap.root.child_count
    @engine.persist_man.load 'xyz'
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_skip_line
    o = GlooLang::Persist::FileLoader.new( @engine, '' )
    assert o.skip_line? ''
    assert o.skip_line? '   '
    assert o.skip_line? "   \n"
    assert o.skip_line? "\t"
    assert o.skip_line? '# '
    assert o.skip_line? ' # comment '
    assert o.skip_line? " \t # "

    refute o.skip_line? 'go [can] :'
    refute o.skip_line? 's [string] : # '
  end

  def test_load_file_that_loads_second_file
    i = @engine.parser.parse_immediate 'load sub/a'
    i.run
    assert_equal 2, @engine.heap.root.child_count
    a = @engine.heap.root.children.first
    assert a
    assert_equal 'a', a.name

    b = @engine.heap.root.children.last
    assert b
    assert_equal 'b', b.name
    assert_equal 'loaded', b.value
  end

end
