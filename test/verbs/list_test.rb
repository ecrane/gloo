require 'test_helper'

class ListTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'list', Gloo::Verbs::List.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '.', Gloo::Verbs::List.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::List.doc_data
    assert_equal Gloo::Verbs::List.keyword, data[:name]
    assert_equal Gloo::Verbs::List.keyword_shortcut, data[:shortcut]
  end

  def test_determine_target
    assert @engine.running
    i = @engine.parser.parse_immediate 'list'
    target = i.determine_target
    assert_same @engine.heap.context, target

    i = @engine.parser.parse_immediate 'list me'
    target = i.determine_target
    refute_same @engine.heap.context, target
    assert_equal 'me', target.to_s
  end

  def test_help_not_fount
    @engine.parser.run 'list asjdfajkfjekajfe'
    assert @engine.error?
    msg = Gloo::Verbs::List::TARGET_MISSING_ERR
    assert @engine.heap.error.value.start_with? msg
  end

  # -------------------------------------------------------------------
  #   list_docs setting
  # -------------------------------------------------------------------

  def test_list_docs_off_by_default_does_not_show_the_doc
    @engine.log.quiet = false
    @engine.parser.run 'create s as string : hi'
    @engine.heap.root.find_child( 's' ).doc = 'The doc for s.'

    out, = capture_io { @engine.parser.run 'list' }
    refute_includes out, 'The doc for s.'
  end

  def test_list_docs_on_shows_the_doc_for_any_object_that_has_one
    @engine.log.quiet = false
    @engine.settings.instance_variable_set( :@list_docs, true )
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.s as string : hi'
    c = @engine.heap.root.find_child( 'c' )
    c.doc = 'The doc for c.'
    c.find_child( 's' ).doc = 'The doc for s.'

    out, = capture_io { @engine.parser.run 'list c' }
    assert_includes out, 'The doc for c.'
    assert_includes out, 'The doc for s.'
  end

  def test_list_docs_on_is_silent_for_an_object_with_no_doc
    @engine.log.quiet = false
    @engine.settings.instance_variable_set( :@list_docs, true )
    @engine.parser.run 'create s as string : hi'

    out, = capture_io { @engine.parser.run 'list' }
    refute_includes out, '#'
  end

end
