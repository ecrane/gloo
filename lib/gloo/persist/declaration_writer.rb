# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Writes the text a save generates: a changed declaration (its head
# kept as written, only the value written again) or a declaration for
# a new object, in the file's style (see FileStyle).
#
# A value is written so it loads back the same: on the line, as a
# BEGIN/END block (exactly as it is -- a block's lines are the value),
# or as a script body. A value with no exact spelling is written as
# the closest one, with a warning.
#

module Gloo
  module Persist
    class DeclarationWriter

      BEGIN_BLOCK = 'BEGIN'.freeze
      END_BLOCK = 'END'.freeze
      SEP = ' : '.freeze
      NOT_EXACT = "Could not save '%s' exactly: %s.".freeze
      NO_FINAL_NEWLINE = 'a block value always ends with a newline'.freeze
      END_LINE = 'a line that is just END ends the block early'.freeze
      NOT_UTF8 = 'it is not valid UTF-8'.freeze

      #
      # Set up a writer for a file with the given style.
      #
      def initialize( engine, style )
        @engine = engine
        @style = style
      end

      #
      # The new text of a declaration whose object's value changed: its
      # head as written, then the value.
      #
      def changed_text( node )
        obj = node.obj
        return body_text( node.head, node.raw_tail, obj, body_indent( node ), trailing_blanks( node ) ) if body?( obj, node.block_style == :body )

        return value_text( node.head, separator( node ), obj, node.raw_indent, node.block_style == :begin_end )
      end

      #
      # A source node for a new object (without its children), at the
      # given indentation, written with the given name (its own, or a
      # dotted path for a shorthand line).
      #
      def new_node( obj, indent, name = obj.name )
        spelled = @style.type_for( obj )
        head = spelled ? "#{indent}#{name} [#{spelled}]" : "#{indent}#{name}"
        node = Source::ObjNode.new( :name => name, :raw_type => spelled || obj.type_display )
        node.raw_indent = indent
        node.head = head
        node.obj = obj
        node.raw = if body?( obj, false )
                     body_text( head, ' :', obj, "#{indent}#{@style.unit}", '' )
                   else
                     value_text( head, SEP, obj, indent, false )
                   end
        node.block_style = block_style_of( node.raw )
        node.raw_tail = node.raw.scrub.lines.first.chomp.delete_prefix( head )
        return node
      end

      private

      # ---------------------------------------------------------------------
      #    Script bodies
      # ---------------------------------------------------------------------

      #
      # Is the value written as a script body: a multi-line value (a
      # script) whose value is a list of lines, or that was a body?
      #
      def body?( obj, was_body )
        return false unless obj.multiline_value?

        return was_body || obj.value_is_array?
      end

      #
      # A script body: the head and tail (eg. ' :'), then each command
      # on its own line at the body's indentation, then any blank lines
      # that followed the body as written.
      #
      def body_text( head, tail, obj, indent, trailing )
        lines = script_lines( obj )
        str = "#{head}#{tail.rstrip}\n"
        lines.each { |line| str << "#{indent}#{line}\n" }
        return "#{str}#{trailing}"
      end

      #
      # A script's command lines, whatever form its value is in.
      #
      def script_lines( obj )
        return obj.value if obj.value_is_array?
        return [] if obj.value.to_s.strip.empty?

        return [ obj.value.to_s.strip ]
      end

      #
      # The indentation of a body as written: its first non-blank line's,
      # or one step in from the declaration.
      #
      def body_indent( node )
        line = node.raw.lines.drop( 1 ).find { |l| !l.strip.empty? }
        return line[ /\A[ \t]*/ ] if line

        return "#{node.raw_indent}#{@style.unit}"
      end

      #
      # The blank lines at the end of a body as written, kept when the
      # body is written again.
      #
      def trailing_blanks( node )
        lines = node.raw.lines.drop( 1 )
        blanks = []
        blanks.unshift( lines.pop ) while lines.any? && lines.last.strip.empty?
        return blanks.join
      end

      # ---------------------------------------------------------------------
      #    Values on the line or in a BEGIN/END block
      # ---------------------------------------------------------------------

      #
      # The declaration with its value: on the line if it can be written
      # there, otherwise as a BEGIN/END block. A value that was a block
      # stays one if it still ends with a newline.
      #
      def value_text( head, sep, obj, indent, was_block )
        value = obj.value_display.to_s
        warn_not_exact( obj, NOT_UTF8 ) unless value.valid_encoding?
        return block_text( head, sep, obj, value, indent ) if block?( value, was_block )
        return "#{head}#{sep.rstrip}\n" if value.empty?

        return "#{head}#{sep}#{value}\n"
      end

      #
      # Does the value need (or keep) a BEGIN/END block? A line break
      # can't go on the line, and a value ending in a backslash or in
      # BEGIN would be read as a continuation or a block start.
      #
      def block?( value, was_block )
        return true if was_block && value.end_with?( "\n" )

        clean = value.scrub
        return clean.include?( "\n" ) || clean.end_with?( '\\' ) || clean.strip.end_with?( BEGIN_BLOCK )
      end

      #
      # A BEGIN/END block: the value's lines exactly as they are, and END
      # lined up with the declaration.
      #
      def block_text( head, sep, obj, value, indent )
        content = value
        unless content.end_with?( "\n" )
          warn_not_exact( obj, NO_FINAL_NEWLINE )
          content = "#{content}\n"
        end
        warn_not_exact( obj, END_LINE ) if content.scrub.lines.any? { |l| l.strip == END_BLOCK }

        return "#{head}#{sep}#{BEGIN_BLOCK}\n#{content}#{indent}#{END_BLOCK}\n"
      end

      #
      # What goes between a declaration's head and its value, as written:
      # usually ' : '.
      #
      def separator( node )
        tail = node.raw_tail.to_s
        return tail.sub( /#{BEGIN_BLOCK}\s*\z/o, '' ) if node.block_style == :begin_end

        value = node.raw_value.to_s
        return tail[ 0, tail.length - value.length ] if !value.empty? && tail.end_with?( value )

        trimmed = tail.rstrip
        return trimmed.end_with?( ':' ) ? "#{trimmed} " : SEP
      end

      #
      # The block style of a declaration written from scratch.
      #
      def block_style_of( text )
        text = text.scrub
        first = text.lines.first.to_s
        return :begin_end if first.rstrip.end_with?( BEGIN_BLOCK ) && text.lines.size > 1
        return :body if text.lines.size > 1

        return :inline
      end

      #
      # Warn that a value is saved as the closest thing gloo can write.
      #
      def warn_not_exact( obj, why )
        @engine.warn format( NOT_EXACT, obj.pn, why )
      end

    end
  end
end
