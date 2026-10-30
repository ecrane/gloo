# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# One object declaration in a source file, eg.
#   name [type] : value
# Carries the declaration's exact source text, plus a back-reference
# to the heap object it created (or named again), so a save can tell
# whether the object is still there and its value unchanged and, if
# so, write the text back exactly as it was read.
#

module Gloo
  module Persist
    module Source
      class ObjNode

        # block_style is one of:
        #  :inline    -- name [type] : value, all on one line
        #  :begin_end -- name [type] : BEGIN ... END
        #  :body      -- name [type] :, followed by an indented,
        #                unparsed body (script commands)
        #
        # raw is the declaration's own exact text: its line (with any
        # continuation lines), and its BEGIN/END block or script body,
        # line endings included -- not its leading_doc or children.
        # head is the declaration line up to its value (indent, name and
        # [type], as written), raw_tail what follows it.
        #
        # repaired_head is set when gloo had to guess at the head (a
        # missing name or ']'): a save writes the head as understood.
        #
        # home is the object's parent and snapshot a copy of its value,
        # both taken when the file finished loading: the object is still
        # in its place if its parent is home, and unchanged if its value
        # equals the snapshot.
        attr_accessor :name, :raw_type, :raw_indent, :raw_tail, :block_style,
                      :raw_value, :leading_doc, :obj, :raw, :head,
                      :home, :snapshot, :repaired_head
        attr_reader :children

        #
        # Set up an object declaration node. Everything but the name
        # and raw type is optional and commonly set afterward via the
        # accessors above -- keeping the initializer small.
        #
        def initialize( name:, raw_type: )
          @name = name
          @raw_type = raw_type
          @raw_indent = ''
          @raw_tail = ''
          @block_style = :inline
          @raw_value = nil
          @leading_doc = nil
          @obj = nil
          @raw = ''
          @head = ''
          @home = nil
          @snapshot = nil
          @repaired_head = nil
          @children = []
        end

        #
        # The exact source text of the declaration, its leading_doc and
        # everything under it, as read.
        #
        def text
          str = "#{@leading_doc}#{@raw}"
          @children.each { |child| str << child.text }
          return str
        end

        #
        # A copy of this declaration with no children, and with the
        # given text in place of its own (for a save's new document;
        # this node is left as it is).
        #
        def detached( raw = @raw )
          copy = dup
          copy.raw = raw
          copy.reset_children
          return copy
        end

        #
        # A copy with the head gloo understood in place of the one
        # written (see repaired_head); this node if nothing was repaired.
        #
        def repaired
          return self unless @repaired_head

          copy = detached( @raw.sub( @head, @repaired_head ) )
          copy.head = @repaired_head
          copy.repaired_head = nil
          return copy
        end

        #
        # Record where the object is and what its value is, now that the
        # file has finished loading.
        #
        def remember
          return unless @obj

          @home = @obj.parent
          @snapshot = copy_of( @obj.value )
        end

        #
        # Is the object still under the parent it was loaded under?
        #
        def in_place?
          return false unless @obj && @home

          return @obj.parent.equal?( @home ) && @home.children.any? { |c| c.equal?( @obj ) }
        end

        #
        # Has the object's value changed since the file was loaded?
        #
        def changed?
          return false unless @obj

          return @obj.value != @snapshot
        end

        #
        # The cleaned-up leading_doc: each line's leading whitespace and
        # its '#' marker (plus one following space, if any) stripped,
        # then the result dedented to its shallowest line. The full
        # block is kept as written, blank '#' lines at the top/bottom
        # included -- it's a faithful reproduction of the comment, not
        # a trimmed summary. '' when there's no leading_doc at all.
        #
        def doc
          return '' unless @leading_doc

          lines = @leading_doc.split( "\n" ).map { |l| strip_marker( l ) }
          return dedent( lines ).join( "\n" )
        end

        #
        # Give the declaration a new name as written (eg. a dotted path
        # when it moves into a file of its own). Only the name on its
        # first line changes.
        #
        def rename( new_name )
          @raw = @raw.sub( /\A([ \t]*)#{Regexp.escape( @name )}/ ) { "#{$1}#{new_name}" }
          @head = @head.sub( /\A([ \t]*)#{Regexp.escape( @name )}/ ) { "#{$1}#{new_name}" }
          @name = new_name
        end

        #
        # Move the declaration (and everything under it) to a new
        # indentation. Its own lines and its script body shift by the
        # same amount; a BEGIN/END block's content is the value, so it
        # stays exactly as it is, and END lines up with the declaration.
        # A leading_doc's lines are set to the new indentation.
        #
        def reindent( new_indent )
          old = @raw_indent
          @leading_doc = reindent_doc( @leading_doc, new_indent ) if @leading_doc
          @raw = reindent_own( @raw, old, new_indent )
          @head = shift( @head, old, new_indent )
          @raw_indent = new_indent
          @children.each do |child|
            next unless child.is_a?( ObjNode )

            child.reindent( shift( child.raw_indent, old, new_indent ) )
          end
        end

        protected

        #
        # Start with no children (for a detached copy).
        #
        def reset_children
          @children = []
        end

        private

        #
        # A copy of a value that can't be changed through the original
        # (a script's lines are an Array that grows in place).
        #
        def copy_of( value )
          return Marshal.load( Marshal.dump( value ) )
        rescue TypeError
          return value.dup
        end

        #
        # The declaration's own lines at a new indentation.
        #
        def reindent_own( text, old, new_indent )
          lines = text.lines
          return text if lines.empty?

          if @block_style == :begin_end
            ending = lines.last[ /\r?\n\z/ ].to_s
            lines[ 0 ] = shift( lines[ 0 ], old, new_indent )
            lines[ -1 ] = "#{new_indent}END#{ending}" if lines.size > 1
            return lines.join
          end

          return lines.map { |l| l.strip.empty? ? l : shift( l, old, new_indent ) }.join
        end

        #
        # Replace a line's old indentation prefix with the new one; a
        # line that doesn't start with it gets the new one added.
        #
        def shift( line, old, new_indent )
          return "#{new_indent}#{line.delete_prefix( old )}" if line.start_with?( old )

          return "#{new_indent}#{line.lstrip}"
        end

        #
        # Re-indent a leading_doc's lines to new_indent, replacing
        # whatever leading whitespace each '#' line had.
        #
        def reindent_doc( raw, new_indent )
          return raw.lines.map { |line| "#{new_indent}#{line.lstrip}" }.join
        end

        #
        # One raw comment line -> its text past the '#': leading
        # whitespace dropped, then the '#' and at most one space after
        # it, then trailing whitespace dropped.
        #
        def strip_marker( raw )
          return raw.lstrip.sub( /\A#\x20?/, '' ).rstrip
        end

        #
        # Remove the common leading whitespace shared by every non-blank
        # line, so a comment block indented for readability (eg. a
        # bullet list within it) keeps its relative indentation.
        #
        def dedent( lines )
          non_blank = lines.reject( &:empty? )
          return lines if non_blank.empty?

          n = non_blank.map { |l| l[ /\A */ ].length }.min
          return lines if n.zero?

          return lines.map { |l| l.empty? ? l : l[ n.. ] }
        end

      end
    end
  end
end
