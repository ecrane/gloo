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

  def test_cross_file_redeclaration_with_a_different_value_warns
    warnings = []
    @engine.log.define_singleton_method( :warn ) { |msg| warnings << msg }

    @engine.persist_man.load 'sub/dup_a'
    @engine.persist_man.load 'sub/dup_b'

    # the first file's value is kept
    assert_equal 'from A', @engine.heap.root.find_child( 'app' ).find_child( 'name' ).value
    assert warnings.any? { |w| w.include?( "'name' is already declared" ) }, warnings.inspect

    # but file B still contributes its own new child
    assert_equal 'only in B', @engine.heap.root.find_child( 'app' ).find_child( 'extra' ).value
  end

  def test_cross_file_redeclaration_with_the_same_value_does_not_warn
    warnings = []
    @engine.log.define_singleton_method( :warn ) { |msg| warnings << msg }

    @engine.persist_man.load 'sub/dup_a'
    @engine.persist_man.load 'sub/dup_a'

    assert_equal [], warnings.select { |w| w.include?( 'already declared' ) }
  end

  def test_same_file_duplicate_name_does_not_warn
    warnings = []
    @engine.log.define_singleton_method( :warn ) { |msg| warnings << msg }

    @engine.persist_man.load 'sub/intra_dup'

    assert_equal 'first', @engine.heap.root.find_child( 'holder' ).find_child( 'd' ).value
    assert_equal [], warnings.select { |w| w.include?( 'already declared' ) },
                 'a documented first-wins duplicate inside one file should be silent'
  end

  def test_nested_container_shorthand_builds_the_chain
    @engine.persist_man.load 'sub/shorthand'
    root = @engine.heap.root

    page = root.find_child( 'page' )
    assert page
    assert_equal 'container', page.type_display
    core = page.find_child( 'core' )
    assert_equal 'container', core.type_display

    list = core.find_child( 'users' ).find_child( 'list' )
    assert_equal 'container', list.type_display
    assert_equal 'Users', list.find_child( 'title' ).value

    # the second shorthand line reuses the same 'core' container
    assert_equal 'defaults', core.find_child( 'settings' ).value
  end

  def test_shorthand_source_node_keeps_the_dotted_name
    @engine.persist_man.load 'sub/shorthand'
    doc = @engine.persist_man.maps.last.source_doc

    names = doc.roots.map( &:name )
    assert_includes names, 'page.core.users.list'
    assert_includes names, 'page.core.settings'
  end

  def test_shorthand_registers_the_top_container_as_a_root
    @engine.persist_man.load 'sub/shorthand'
    fs = @engine.persist_man.maps.last

    assert_equal 1, fs.roots.length
    assert_equal 'page', fs.roots.first.name
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

  def test_script_body_with_inline_comments_loads_runs_and_keeps_the_comments
    @engine.log.quiet = true
    @engine.persist_man.load 'sub/inline_comments'
    refute @engine.error?, 'the inline-comment lines should not error on load/run'

    script = @engine.heap.root.children.first.find_child( 'on_load' )
    # comments are kept verbatim in the stored script lines (for save
    # round-trip); they're only ignored when the line is executed.
    assert script.value.any? { |line| line.include?( '# inline comment on a boolean' ) }
  end

  def test_source_doc_round_trips_a_body_with_inline_comments
    @engine.persist_man.load 'sub/inline_comments'
    doc = @engine.persist_man.maps.last.source_doc
    node = doc.roots.first.children.find do |n|
      n.is_a?( Gloo::Persist::Source::ObjNode ) && n.name == 'on_load'
    end
    assert_includes node.raw_value, "# inline comment after a quoted string"
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

  # -------------------------------------------------------------------
  #   Robustness against messy input
  # -------------------------------------------------------------------

  def test_trailing_whitespace_after_script_colon_still_starts_a_body
    @engine.log.quiet = true
    @engine.persist_man.load 'sub/ws_script'
    holder = @engine.heap.root.children.first
    refute @engine.error?

    script = holder.find_child( 'on_load' )
    assert_equal [ 'show "hi"', 'show "bye"' ], script.value
    assert_equal 'sib', holder.find_child( 'after' ).value, 'the sibling should not be swallowed'
  end

  def test_a_line_that_outdents_past_the_root_does_not_crash
    require 'tmpdir'
    dir = Dir.mktmpdir
    # tab, then 3-tab, then a space-indented line -- erratic enough to
    # outdent further than it ever indented
    File.write( File.join( dir, 'messy.gloo' ),
                "root [container] :\n\t\t\tdeep [string] : x\n  shallow [string] : y\n" )
    @engine.settings.override_project_path( "#{dir}/" )
    @engine.log.quiet = true

    @engine.persist_man.load 'messy' # used to raise on an emptied indent stack
    refute @engine.error?
    assert @engine.heap.root.find_child( 'root' )
  ensure
    FileUtils.remove_entry dir if dir
  end

  def test_an_unknown_type_followed_by_an_indented_line_does_not_crash
    require 'tmpdir'
    dir = Dir.mktmpdir
    File.write( File.join( dir, 'bad.gloo' ),
                "c [container] :\n\tx [nosuchtype] :\n\t\tchild [string] : v\n" )
    @engine.settings.override_project_path( "#{dir}/" )
    @engine.log.quiet = true

    @engine.persist_man.load 'bad' # 'nosuchtype' -> nil obj -> used to push nil as a parent
    refute @engine.error?
    assert @engine.heap.root.find_child( 'c' )
  ensure
    FileUtils.remove_entry dir if dir
  end

  # -------------------------------------------------------------------
  #   Obj#doc -- the cleaned leading_doc, copied onto the heap object
  # -------------------------------------------------------------------

  def test_leading_doc_reaches_the_heap_object
    @engine.persist_man.load 'sub/comments'
    demo = @engine.heap.root.find_child( 'demo' )

    # the fixture's comment is padded with blank '#' lines above and
    # below -- the full block is kept, not just the text in the middle
    assert_equal "\nleading doc comment for demo\n", demo.doc
    assert_equal 'leading doc for msg', demo.find_child( 'msg' ).doc
    assert_equal '', demo.find_child( 'other' ).doc
  end

  def test_first_non_empty_doc_wins_across_files
    require 'tmpdir'
    dir = Dir.mktmpdir
    File.write( File.join( dir, 'a.gloo' ),
                "# from A\napp [container] :\n\tname [string] : from A\n" )
    File.write( File.join( dir, 'b.gloo' ), "app [container] :\n\tname [string] : from B\n" )
    @engine.settings.override_project_path( "#{dir}/" )
    @engine.log.quiet = true

    @engine.persist_man.load 'a'
    @engine.persist_man.load 'b'

    app = @engine.heap.root.find_child( 'app' )
    assert_equal 'from A', app.doc
  ensure
    FileUtils.remove_entry dir if dir
  end

  def test_a_comment_less_redeclaration_does_not_blank_an_earlier_doc
    require 'tmpdir'
    dir = Dir.mktmpdir
    File.write( File.join( dir, 'b.gloo' ), "app [container] :\n\tname [string] : from B\n" )
    File.write( File.join( dir, 'a.gloo' ),
                "# from A\napp [container] :\n\tname [string] : from A\n" )
    @engine.settings.override_project_path( "#{dir}/" )
    @engine.log.quiet = true

    # loaded in the opposite order this time -- the commented file second
    @engine.persist_man.load 'b'
    @engine.persist_man.load 'a'

    app = @engine.heap.root.find_child( 'app' )
    assert_equal 'from A', app.doc
  ensure
    FileUtils.remove_entry dir if dir
  end

end
