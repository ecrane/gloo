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

  # -------------------------------------------------------------------
  #   SourceDoc
  # -------------------------------------------------------------------

  def test_source_doc_captures_leading_and_floating_comments
    @engine.persist_man.load 'sub/comments'
    doc = @engine.persist_man.maps.last.source_doc

    demo = doc.roots.first
    assert_equal 'demo', demo.name
    assert_equal "#\n# leading doc comment for demo\n#", demo.leading_doc

    msg_node = demo.children.find { |n| n.is_a?( Gloo::Persist::Source::ObjNode ) && n.name == 'msg' }
    assert_equal '  # leading doc for msg', msg_node.leading_doc

    # the detached comment floats as its own node, followed by a blank
    # line node, both ahead of 'other' -- which gets no leading_doc.
    trivia = demo.children.select { |n| !n.is_a?( Gloo::Persist::Source::ObjNode ) }
    assert trivia.any? { |n| n.is_a?( Gloo::Persist::Source::CommentNode ) &&
      n.raw.include?( 'detached from other' ) }
    assert trivia.any? { |n| n.is_a?( Gloo::Persist::Source::BlankNode ) }

    other_node = demo.children.find { |n| n.is_a?( Gloo::Persist::Source::ObjNode ) && n.name == 'other' }
    assert_nil other_node.leading_doc
  end

  def test_source_doc_preserves_blank_lines
    @engine.persist_man.load 'sub/comments'
    doc = @engine.persist_man.maps.last.source_doc
    demo = doc.roots.first

    assert demo.children.any? { |n| n.is_a?( Gloo::Persist::Source::BlankNode ) }
  end

  def test_source_doc_captures_begin_end_block_raw
    @engine.persist_man.load 'sub/block_lines'
    doc = @engine.persist_man.maps.last.source_doc
    body_node = doc.roots.first.children.first

    assert_equal 'body', body_node.name
    assert_equal :begin_end, body_node.block_style
    assert_includes body_node.raw_value, '# not a comment here'
  end

  def test_source_doc_multiple_roots
    @engine.persist_man.load 'ctrl/invoke'
    doc = @engine.persist_man.maps.last.source_doc

    names = doc.roots.map( &:name )
    assert_equal %w[f add not_a_function greet failing], names
    assert_equal doc.roots.length, @engine.persist_man.maps.last.roots.length
  end

  def test_source_doc_root_leading_doc_across_files
    @engine.persist_man.load 'ctrl/invoke'
    doc = @engine.persist_man.maps.last.source_doc

    add_node = doc.roots.find { |n| n.name == 'add' }
    assert_includes add_node.leading_doc, 'Function with declared params'
  end

  def test_empty_script_does_not_swallow_the_next_object
    @engine.persist_man.load 'sub/empty_script'
    holder = @engine.heap.root.children.first
    assert_equal 4, holder.child_count

    names = holder.children.map( &:name )
    assert_equal %w[empty_script after_empty comment_only_script after_comment_only], names

    after_empty = holder.find_child( 'after_empty' )
    assert_equal 'still here', after_empty.value
    after_comment_only = holder.find_child( 'after_comment_only' )
    assert_equal 'also here', after_comment_only.value
  end

  def test_script_body_comment_is_kept_in_source_but_not_run_as_a_command
    @engine.persist_man.load 'sub/empty_script'
    holder = @engine.heap.root.children.first
    comment_only = holder.find_child( 'comment_only_script' )

    # not executed as a command -- the body stayed empty/blank
    assert comment_only.value_is_blank? || comment_only.value == []

    doc = @engine.persist_man.maps.last.source_doc
    node = doc.roots.first.children.find do |n|
      n.is_a?( Gloo::Persist::Source::ObjNode ) && n.name == 'comment_only_script'
    end
    assert_equal :body, node.block_style
    assert_includes node.raw_value, '# just a note, no commands'
  end

  def test_source_doc_captures_lib_directive
    dm = Gloo::Persist::FileLoader.instance_method( :run_lib_directive )
    Gloo::Persist::FileLoader.send( :define_method, :run_lib_directive ) { |_line| nil }

    begin
      @engine.persist_man.load 'sub/uses_lib'
      doc = @engine.persist_man.maps.last.source_doc
      directive = doc.children.find { |n| n.is_a?( Gloo::Persist::Source::DirectiveNode ) }
      assert directive
      assert_equal 'load lib yaml', directive.raw
    ensure
      Gloo::Persist::FileLoader.send( :define_method, :run_lib_directive, dm )
    end
  end

end
