require 'test_helper'
require 'tmpdir'

#
# Load, change, save: each scenario checks that only the expected lines
# change, and that loading the saved files into a fresh engine gives the
# same objects as the live ones. Scripts run as usual.
#
class SaveScenariosTest < BaseEngineTest

  def setup
    super
    @dir = Dir.mktmpdir
    @engine.settings.override_project_path( "#{@dir}/" )
  end

  def teardown
    FileUtils.remove_entry @dir
    super
  end

  # ---------------------------------------------------------------------
  #    Helpers
  # ---------------------------------------------------------------------

  #
  # Write a file into the scratch folder and load it.
  #
  def load_file( name, text )
    File.binwrite( path( name ), text )
    @engine.persist_man.load( path( name ) )
  end

  #
  # The full path of a scratch file.
  #
  def path( name )
    return File.join( @dir, "#{name}.gloo" )
  end

  #
  # A scratch file's contents.
  #
  def read( name )
    return File.binread( path( name ) ).force_encoding( Encoding::UTF_8 )
  end

  #
  # Run gloo commands.
  #
  def gloo( *cmds )
    cmds.each { |cmd| @engine.parser.run cmd }
  end

  #
  # Load the given files into a fresh engine and check that each named
  # root has the same objects (names, types and values) as the live one.
  #
  def assert_reloads_the_same( files, roots )
    fresh = Gloo::App::Engine.new( default_context )
    fresh.log.quiet = true
    fresh.start
    files.each { |f| fresh.persist_man.load( path( f ) ) }
    roots.each do |name|
      assert_equal tree( @engine.heap.root.find_child( name ) ),
                   tree( fresh.heap.root.find_child( name ) ), "#{name} reloads differently"
    end
  end

  #
  # An object and everything under it as nested arrays.
  #
  def tree( obj )
    return nil unless obj

    # A container's value is nil when created, '' when loaded.
    value = obj.value.nil? ? '' : obj.value
    return [ obj.name, obj.type_display, value, obj.children.map { |c| tree( c ) } ]
  end

  # ---------------------------------------------------------------------
  #    Changes to values
  # ---------------------------------------------------------------------

  def test_an_edit_changes_only_that_line
    load_file 'a', "# app\napp [can] :\n  # the name\n  name [string] : old  \n  n [int] : 1\n"
    gloo "put 'new' into app.name"
    gloo 'save app'
    assert_equal "# app\napp [can] :\n  # the name\n  name [string] : new\n  n [int] : 1\n", read( 'a' )
    assert_reloads_the_same [ 'a' ], [ 'app' ]
  end

  def test_a_message_that_changes_a_value_changes_only_that_line
    load_file 'a', "app [can] :\n  n [int] : 1\n  m [int] : 7\n"
    gloo 'tell app.n to inc'
    gloo 'save app'
    assert_equal "app [can] :\n  n [int] : 2\n  m [int] : 7\n", read( 'a' )
  end

  def test_a_value_changed_and_changed_back_is_untouched
    text = "app [can] :\n  n [int] :    1\n"
    load_file 'a', text
    gloo 'put 5 into app.n', 'put 1 into app.n'
    gloo 'save app'
    assert_equal text, read( 'a' )
  end

  def test_changes_outside_the_file_leave_it_untouched
    text = "app [can] :\n  n [int] : 1\n  s [script] :\n    put 1 into app.n\n\n    # done\n"
    load_file 'a', text
    gloo 'create other as can', 'create other.z as int : 4', 'put 9 into other.z'
    gloo 'tell app.s to run'
    gloo 'save app'
    assert_equal text, read( 'a' )
  end

  def test_a_changed_untyped_declaration_stays_untyped
    load_file 'a', "app [can] :\n  plain : old value\n"
    gloo "put 'new value' into app.plain"
    gloo 'save app'
    assert_equal "app [can] :\n  plain : new value\n", read( 'a' )
  end

  def test_a_changed_script_body_keeps_its_indentation_and_trailing_blank_lines
    load_file 'a', "app [can] :\n  s [script] :\n      show 1\n      # a note\n\n  after [int] : 1\n"
    gloo "put 'show 2' into app.s"
    gloo 'save app'
    assert_equal "app [can] :\n  s [script] :\n      show 2\n\n  after [int] : 1\n", read( 'a' )
  end

  # ---------------------------------------------------------------------
  #    Values that need a block, or can't be written exactly
  # ---------------------------------------------------------------------

  def test_appending_to_a_text_value_does_not_indent_it
    load_file 'a', "notes [can] :\n  log [text] : BEGIN\nStarted.\nEND\n  entry [text] : BEGIN\nSaved.\nEND\n"
    2.times do
      gloo 'put notes.log + notes.entry into notes.log'
      gloo 'save notes'
    end
    assert_equal "notes [can] :\n  log [text] : BEGIN\nStarted.\nSaved.\nSaved.\n  END\n" \
                 "  entry [text] : BEGIN\nSaved.\nEND\n", read( 'a' )
    assert_reloads_the_same [ 'a' ], [ 'notes' ]
  end

  def test_a_value_ending_in_a_backslash_is_written_as_a_block
    load_file 'a', "app [can] :\n  p [string] : x\n  q [string] : y\n"
    @engine.heap.root.find_child( 'app' ).find_child( 'p' ).set_value( 'C:\\dir\\' )
    gloo 'save app'
    assert_equal "app [can] :\n  p [string] : BEGIN\nC:\\dir\\\n  END\n  q [string] : y\n", read( 'a' )
  end

  def test_a_value_ending_in_begin_is_written_as_a_block
    load_file 'a', "app [can] :\n  p [string] : x\n"
    gloo "put 'press BEGIN' into app.p"
    gloo 'save app'
    assert_includes read( 'a' ), "  p [string] : BEGIN\npress BEGIN\n  END\n"
  end

  def test_a_block_value_with_no_final_newline_warns
    load_file 'a', "app [can] :\n  t [text] : BEGIN\nStarted.\nEND\n"
    warnings = capture_warnings { gloo "put app.t + 'Done.' into app.t", 'save app' }
    assert_equal "app [can] :\n  t [text] : BEGIN\nStarted.\nDone.\n  END\n", read( 'a' )
    assert warnings.any? { |w| w.include?( "Could not save 'app.t' exactly: a block value always ends with a newline." ) }
  end

  # ---------------------------------------------------------------------
  #    New and deleted objects
  # ---------------------------------------------------------------------

  def test_a_new_child_follows_the_files_style
    load_file 'a', "app [can] :\n  n [int] : 1\n  box [can] :\n    x [int] : 2\n"
    gloo 'create app.k as integer : 5', 'create app.box.y as container'
    gloo 'save app'
    assert_equal "app [can] :\n  n [int] : 1\n  box [can] :\n    x [int] : 2\n    y [can] :\n  k [int] : 5\n", read( 'a' )
    assert_reloads_the_same [ 'a' ], [ 'app' ]
  end

  def test_a_new_child_in_a_tab_file_uses_tabs
    load_file 'a', "app [container] :\n\tn [integer] : 1\n"
    gloo 'create app.k as int : 5'
    gloo 'save app'
    assert_equal "app [container] :\n\tn [integer] : 1\n\tk [integer] : 5\n", read( 'a' )
  end

  def test_deleting_an_object_drops_its_lines_and_doc
    load_file 'a', "app [can] :\n  # about x\n  x [can] :\n    y [int] : 1\n  z [int] : 2\n"
    gloo 'tell app.x to unload'
    gloo 'save app'
    assert_equal "app [can] :\n  z [int] : 2\n", read( 'a' )
  end

  def test_a_recreated_object_is_a_new_object
    load_file 'a', "app [can] :\n  # about x\n  x [string] : old\n  z [int] : 2\n"
    gloo 'tell app.x to unload', "create app.x as string : new"
    gloo 'save app'
    assert_equal "app [can] :\n  z [int] : 2\n  x [string] : new\n", read( 'a' )
  end

  def test_a_file_with_no_final_newline_keeps_it_that_way
    load_file 'a', "app [can] :\n  n [int] : 1"
    gloo 'create app.k as int : 5'
    gloo 'save app'
    assert_equal "app [can] :\n  n [int] : 1\n  k [int] : 5", read( 'a' )
  end

  def test_a_new_child_of_a_shorthand_container_is_a_shorthand_line
    load_file 'a', "page.core.users [can] :\n  n [int] : 1\n# end\n"
    gloo "create page.core.x as string : v"
    gloo 'save page'
    assert_equal "page.core.users [can] :\n  n [int] : 1\npage.core.x [string] : v\n# end\n", read( 'a' )
    assert_reloads_the_same [ 'a' ], [ 'page' ]
  end

  def test_a_shorthand_child_of_a_declared_container_is_written_once
    text = "a [can] :\n  x [int] : 1\n\na.b [can] :\n  y [int] : 2\n"
    load_file 'a', text
    gloo 'save a'
    assert_equal text, read( 'a' )
    gloo 'put 3 into a.b.y', 'save a'
    assert_equal text.sub( 'y [int] : 2', 'y [int] : 3' ), read( 'a' )
  end

  # ---------------------------------------------------------------------
  #    One object, several declarations
  # ---------------------------------------------------------------------

  def test_an_edit_changes_only_the_first_of_same_name_lines
    load_file 'a', "naming [can] :\n  a [string] : First A\n  a [string] : Second A\n  A [string] : Capital\n"
    gloo "put 'Changed' into naming.a"
    gloo 'save naming'
    assert_equal "naming [can] :\n  a [string] : Changed\n  a [string] : Second A\n  A [string] : Capital\n", read( 'a' )
  end

  def test_deleting_an_object_declared_twice_drops_both_lines
    load_file 'a', "naming [can] :\n  a [string] : First A\n  b [int] : 1\n  a [string] : Second A\n"
    gloo 'tell naming.a to unload'
    gloo 'save naming'
    assert_equal "naming [can] :\n  b [int] : 1\n", read( 'a' )
    assert_reloads_the_same [ 'a' ], [ 'naming' ]
  end

  def test_an_edit_in_a_namespace_changes_only_the_file_that_declares_it
    load_file 'a', "app [can] :\n  x [string] : a-x\n  shared [string] : first\n"
    load_file 'b', "app [can] :\n  y [string] : b-y\n  shared [string] : second\n"
    gloo "put 'A-X' into app.x", "put 'S' into app.shared"
    gloo 'save'
    assert_equal "app [can] :\n  x [string] : A-X\n  shared [string] : S\n", read( 'a' )
    assert_equal "app [can] :\n  y [string] : b-y\n  shared [string] : second\n", read( 'b' )
  end

  def test_a_new_child_of_a_namespace_goes_in_the_first_file
    load_file 'a', "app [can] :\n  x [string] : a-x\n"
    load_file 'b', "app [can] :\n  y [string] : b-y\n"
    gloo "create app.fresh as string : new"
    gloo 'save'
    assert_equal "app [can] :\n  x [string] : a-x\n  fresh [string] : new\n", read( 'a' )
    assert_equal "app [can] :\n  y [string] : b-y\n", read( 'b' )
  end

  # ---------------------------------------------------------------------
  #    Moves
  # ---------------------------------------------------------------------

  def test_a_move_in_one_file_carries_the_declaration_and_doc
    load_file 'a', "app [can] :\n  from [can] :\n    # the thing\n    thing [can] :\n      v [int] : 1\n  to [can] :\n    other [int] : 2\n"
    gloo 'move app.from.thing to app.to'
    gloo 'save app'
    assert_equal "app [can] :\n  from [can] :\n  to [can] :\n    other [int] : 2\n    # the thing\n    thing [can] :\n      v [int] : 1\n", read( 'a' )
    assert_reloads_the_same [ 'a' ], [ 'app' ]
  end

  def test_a_move_between_files_saves_both
    load_file 'a', "one [can] :\n  thing [string] : t\n  keep [int] : 1\n"
    load_file 'b', "two [can] :\n  other [int] : 2\n"
    gloo 'move one.thing to two'
    gloo 'save one'
    assert_equal "one [can] :\n  keep [int] : 1\n", read( 'a' )
    assert_equal "two [can] :\n  other [int] : 2\n  thing [string] : t\n", read( 'b' )
    assert_reloads_the_same %w[a b], %w[one two]
  end

  def test_saving_twice_after_a_change_is_stable
    load_file 'a', "app [can] :\n  n [int] : 1\n"
    gloo 'put 2 into app.n', 'create app.k as int : 3', 'save app'
    first = read( 'a' )
    gloo 'save app'
    assert_equal first, read( 'a' )
    refute Gloo::Persist::FileSaver.new( @engine, path( 'a' ), nil,
                                         @engine.persist_man.maps.last.source_doc ).dirty?
  end


  # ---------------------------------------------------------------------
  #    New top-level objects
  # ---------------------------------------------------------------------

  def test_a_bare_save_leaves_out_a_new_top_level_object_and_warns
    text = "app [can] :\n  n [int] : 1\n"
    load_file 'a', text
    gloo 'create notes as can', "create notes.first as string : remember this"
    warnings = capture_warnings { gloo 'save' }
    assert_equal text, read( 'a' )
    assert_includes warnings, 'Not saved (no file yet): notes. Use save notes.'
  end

  def test_a_bare_save_names_every_new_top_level_object
    load_file 'a', "app [can] :\n"
    gloo 'create one as can', 'create two as can'
    warnings = capture_warnings { gloo 'save' }
    assert_includes warnings, 'Not saved (no file yet): one, two. Use save {name} for each.'
  end

  def test_once_saved_a_new_top_level_object_is_an_open_file
    load_file 'a', "app [can] :\n"
    gloo 'create notes as can', 'save notes'
    warnings = capture_warnings { gloo 'save' }
    assert_equal [], warnings
    assert File.exist?( path( 'notes' ) )
  end

  def test_a_bare_save_with_nothing_new_does_not_warn
    load_file 'a', "app [can] :\n"
    assert_equal [], capture_warnings { gloo 'save' }
  end

end
