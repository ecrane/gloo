# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Collects an indented, unparsed script body (no BEGIN/END) for the
# object that was just declared. We don't yet know whether a body
# actually follows -- that's decided by the next line's indentation,
# so this may close immediately with nothing collected (an empty
# script).
#

module Gloo
  module Persist
    class ScriptBodyCollector

      attr_reader :active

      #
      # Set up an inactive collector.
      #
      def initialize
        @active = false
      end

      #
      # Start tentatively collecting a body for the object just
      # declared. node is its Source::ObjNode, heap_obj the object
      # itself, base_tabs the indentation of the declaration line
      # (body lines must be indented deeper than this).
      #
      def start( node, heap_obj, base_tabs )
        @active = true
        @node = node
        @obj = heap_obj
        @base_tabs = base_tabs
        @lines = []
      end

      #
      # One line while a body might be open. line is the line as read
      # (continuations joined), raw its exact source text, line_tabs its
      # indentation (ignored for a blank line, which is always kept).
      # Returns true if the line was consumed as body content, or false
      # if it closed the body and still needs to be dispatched normally
      # by the caller.
      #
      def handle_line( line, raw, line_tabs )
        if line.strip.empty?
          keep( raw )
          return true
        end

        if line_tabs <= @base_tabs
          close
          return false
        end

        keep( raw )
        @obj.add_line( line ) unless line.strip.start_with?( '#' )
        return true
      end

      #
      # End of file with a body still open (eg. the last object in the
      # file is an empty or in-progress script) -- close it so its
      # content isn't silently dropped.
      #
      def finish
        close if @active
      end

      private

      #
      # Keep one body line's exact text: on the node's own text, and in
      # the body's raw value. A comment line is kept but isn't added as a
      # command (a comment inside a script body is documentation, not
      # something to execute).
      #
      def keep( raw )
        @node.raw << raw
        @lines << raw.chomp( "\n" )
      end

      #
      # Close out the body, recording its raw content on the node.
      #
      def close
        @active = false
        @node.raw_value = @lines.join( "\n" )
        @node.block_style = :body unless @lines.empty?
        @node = nil
        @obj = nil
      end

    end
  end
end
