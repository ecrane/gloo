require 'test_helper'

class HelpShellTest < BaseEngineTest

  def setup
    super
    # Base engine tests default to quiet; these tests assert on the
    # shell's actual printed output.
    @engine.log.quiet = false
  end

  def test_prompt
    shell = Gloo::Docs::HelpShell.new( @engine )
    assert_equal 'help> ', shell.prompt
  end

  def test_quit_is_available
    shell = Gloo::Docs::HelpShell.new( @engine )
    capture_io { shell.execute_once( [ 'quit' ] ) }
    assert shell.instance_variable_get( :@context ).done
  end

  def test_verbs_lists_verbs
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( [ 'verbs' ] ) }
    assert_match( /put/, out )
    assert_match( /show/, out )
  end

  def test_objects_lists_object_types
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( [ 'objects' ] ) }
    assert_match( /string/, out )
    assert_match( /container/, out )
  end

  def test_settings_shows_settings
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( [ 'settings' ] ) }
    assert_match( /Application Settings/, out )
  end

  def test_extensions_and_libraries_run_without_error
    shell = Gloo::Docs::HelpShell.new( @engine )
    capture_io { shell.execute_once( [ 'extensions' ] ) }
    capture_io { shell.execute_once( [ 'libraries' ] ) }
    refute @engine.error?
  end

  def test_verb_detail_for_a_documented_verb
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( %w[verb put] ) }
    assert_match( /put/, out )
    assert_match( /Description/, out )
  end

  def test_verb_detail_tab_completion_lists_all_verbs
    shell = Gloo::Docs::HelpShell.new( @engine )
    root = shell.instance_variable_get( :@root )
    ctx = shell.instance_variable_get( :@context )
    result = shell.traverse( root, [ 'verb' ] )
    names = result[ :node ].children( ctx ).map( &:name )
    assert_includes names, 'put'
    assert_includes names, 'show'
  end

  def test_object_detail_tab_completion_lists_all_object_types
    shell = Gloo::Docs::HelpShell.new( @engine )
    root = shell.instance_variable_get( :@root )
    ctx = shell.instance_variable_get( :@context )
    result = shell.traverse( root, [ 'object' ] )
    names = result[ :node ].children( ctx ).map( &:name )
    assert_includes names, 'string'
    assert_includes names, 'container'
  end

  def test_object_detail_for_a_documented_object
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( %w[object container] ) }
    assert_match( /container/, out )
    assert_match( /Description/, out )
  end

  def test_docs_lists_doc_pages
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( [ 'docs' ] ) }
    assert_match( /getting_started/, out )
    assert_match( /operators/, out )
  end

  def test_doc_detail_tab_completion_lists_all_doc_pages
    shell = Gloo::Docs::HelpShell.new( @engine )
    root = shell.instance_variable_get( :@root )
    ctx = shell.instance_variable_get( :@context )
    result = shell.traverse( root, [ 'doc' ] )
    names = result[ :node ].children( ctx ).map( &:name )
    assert_includes names, 'getting_started'
    assert_includes names, 'iterators'
  end

  def test_doc_detail_for_a_documented_page
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( %w[doc getting_started] ) }
    assert_match( /Getting Started/, out )
  end

  def test_doc_detail_for_an_unknown_page
    # Not reachable via execute_once/traverse - dynamic child nodes only
    # ever exist for real page names - so this exercises the guard clause
    # directly, same as it would matter if a page were deleted mid-session.
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.send( :cmd_show_doc_detail, 'nope', nil ) }
    assert_match( /No documentation available yet for 'nope'/, out )
  end

  def test_unknown_command_at_the_root
    shell = Gloo::Docs::HelpShell.new( @engine )
    out, = capture_io { shell.execute_once( [ 'nope' ] ) }
    assert_match( /Unknown command/, out )
  end

end
