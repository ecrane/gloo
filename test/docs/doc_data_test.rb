require 'test_helper'

class DocDataTest < BaseTest

  def test_children_are_shown_when_present
    dd = Gloo::Docs::DocData.new(
      :name => 'container',
      :children => [ 'None by default.' ] )

    out, = capture_io { dd.show_in_terminal }
    assert_match( /## Children/, out )
    assert_match( /- None by default\./, out )
  end

  def test_children_are_not_shown_when_absent
    dd = Gloo::Docs::DocData.new( :name => 'string' )

    out, = capture_io { dd.show_in_terminal }
    refute_match( /## Children/, out )
  end

  def test_messages_are_shown_when_present
    dd = Gloo::Docs::DocData.new(
      :name => 'string',
      :messages => [ 'up — Convert the string to uppercase.' ] )

    out, = capture_io { dd.show_in_terminal }
    assert_match( /## Messages/, out )
    assert_match( /- up — Convert the string to uppercase\./, out )
  end

  def test_messages_are_not_shown_when_absent
    dd = Gloo::Docs::DocData.new( :name => 'string' )

    out, = capture_io { dd.show_in_terminal }
    refute_match( /## Messages/, out )
  end

  def test_notes_are_shown_when_present
    dd = Gloo::Docs::DocData.new(
      :name => 'context',
      :notes => 'A secondary CLI example, or any other freeform aside.' )

    out, = capture_io { dd.show_in_terminal }
    assert_match( /## Notes/, out )
    assert_match( /A secondary CLI example/, out )
  end

  def test_notes_are_not_shown_when_absent
    dd = Gloo::Docs::DocData.new( :name => 'string' )

    out, = capture_io { dd.show_in_terminal }
    refute_match( /## Notes/, out )
  end

  def test_render_returns_a_string_without_printing
    dd = Gloo::Docs::DocData.new(
      :name => 'string',
      :description => 'A string value.' )

    out, = capture_io do
      rendered = dd.render
      assert_kind_of String, rendered
      assert_match( /## Description/, rendered )
    end
    assert_empty out
  end

  def test_show_in_terminal_prints_the_rendered_string
    dd = Gloo::Docs::DocData.new(
      :name => 'string',
      :description => 'A string value.' )

    out, = capture_io { dd.show_in_terminal }
    assert_equal dd.render, out
  end

  def test_object_shaped_data_only_shows_relevant_sections
    dd = Gloo::Docs::DocData.new(
      :name => 'string',
      :shortcut => 'str',
      :description => 'A string value.',
      :messages => [ 'size — Get the size of the string.' ] )

    out, = capture_io { dd.show_in_terminal }
    assert_match( /^# string/, out )
    assert_match( /^str$/, out )
    assert_match( /## Description/, out )
    assert_match( /## Messages/, out )
    refute_match( /## Syntax/, out )
    refute_match( /## Parameters/, out )
    refute_match( /## Children/, out )
    refute_match( /## Result/, out )
    refute_match( /## Errors/, out )
  end

end
