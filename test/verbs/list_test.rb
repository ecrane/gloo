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

  #
  # Regression: doc's full text (including a blank line at the end) is
  # meant to render as its own line. each_line silently drops a
  # trailing empty segment ("a\n".each_line => ["a\n"], not ["a\n", ""]),
  # so show_doc has to split instead.
  #
  def test_list_docs_does_not_drop_a_trailing_blank_comment_line
    @engine.settings.instance_variable_set( :@list_docs, true )
    @engine.parser.run 'create s as string : hi'
    @engine.heap.root.find_child( 's' ).doc = "Line one.\n"

    shown = []
    @engine.log.define_singleton_method( :show ) { |msg, *_| shown << msg }
    @engine.parser.run 'list'

    doc_lines = shown.select { |m| m.include?( '#' ) }
    assert_equal 2, doc_lines.count, shown.inspect
  end

  #
  # A long doc line should word-wrap to fit the terminal, rather than
  # running past its edge as a single unwrapped line.
  #
  def test_list_docs_wraps_a_long_doc_line_to_terminal_width
    @engine.settings.instance_variable_set( :@list_docs, true )
    @engine.parser.run 'create s as string : hi'
    long_doc = ( 'word ' * 30 ).strip
    @engine.heap.root.find_child( 's' ).doc = long_doc

    shown = []
    @engine.log.define_singleton_method( :show ) { |msg, *_| shown << msg }
    @engine.parser.run 'list'

    doc_lines = shown.select { |m| m.include?( 'word' ) }
    assert doc_lines.count > 1, shown.inspect

    cols = Gloo::App::Settings.cols( @engine )
    doc_lines.each do |line|
      plain = line.gsub( /\e\[[0-9;]*m/, '' )
      assert plain.length <= cols, plain
    end
  end

  #
  # A continuation line lines up under the text after '# ', not under
  # the '#' itself -- so only the first wrapped piece of a doc line
  # carries the '#' prefix.
  #
  def test_list_docs_wrap_continuation_lines_have_no_hash_prefix
    @engine.settings.instance_variable_set( :@list_docs, true )
    @engine.parser.run 'create s as string : hi'
    @engine.heap.root.find_child( 's' ).doc = ( 'word ' * 30 ).strip

    shown = []
    @engine.log.define_singleton_method( :show ) { |msg, *_| shown << msg }
    @engine.parser.run 'list'

    doc_lines = shown.select { |m| m.include?( 'word' ) }
    assert doc_lines.count > 1, shown.inspect
    assert_includes doc_lines.first, '#'
    doc_lines[ 1.. ].each do |line|
      refute_includes line, '#'
    end
  end

  #
  # Wrapping never breaks a single long word (e.g. a URL) across lines.
  #
  def test_list_docs_wrap_never_breaks_a_word
    @engine.settings.instance_variable_set( :@list_docs, true )
    @engine.parser.run 'create s as string : hi'
    long_word = "http://example.com/#{'x' * 60}"
    @engine.heap.root.find_child( 's' ).doc = "before #{long_word} after"

    shown = []
    @engine.log.define_singleton_method( :show ) { |msg, *_| shown << msg }
    @engine.parser.run 'list'

    assert_includes shown.join( ' ' ), long_word
  end

end
