require 'test_helper'

class FileLoaderTest < BaseEngineTest

  def test_splitting_a_line
    fs = Gloo::Persist::FileLoader.new( @engine, '' )
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
    fs = Gloo::Persist::FileLoader.new( @engine, '' )

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
    o = Gloo::Persist::FileLoader.new( @engine, '' )
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

  def test_lib_directive_pattern
    re = Gloo::Persist::FileLoader::LIB_DIRECTIVE
    assert re =~ 'load lib yaml'
    assert re =~ "ld ext foo\n"
    assert re =~ 'load  lib  yaml'
    refute re =~ 'load some_file'
    refute re =~ '  load lib yaml'
    refute re =~ 's [string] : load lib yaml'
  end

  def test_load_lib_directive_at_top_of_file_registers_the_type
    refute @engine.dictionary.find_obj( 'yaml' ), 'yaml type should not be registered yet'

    @engine.persist_man.load 'sub/uses_lib'

    assert @engine.dictionary.find_obj( 'yaml' ),
           'the load lib directive should have registered the yaml type'

    obj = @engine.heap.root.children.first
    assert_equal 'uses_lib', obj.name
    cfg = obj.children.first
    assert_equal 'cfg', cfg.name
    assert_equal 'yaml', cfg.class.typename,
                 'the [yaml] object should have been created with its real type'
  end

  def test_begin_end_block_keeps_hash_and_blank_lines
    @engine.persist_man.load 'sub/block_lines'

    body = @engine.heap.root.children.first.children.first
    assert_equal 'body', body.name
    assert_includes body.value, '# not a comment here'
    assert_equal 4, body.value.split( "\n" ).length,
                 'the blank line inside the block should be kept'
  end

end
