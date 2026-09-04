# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Buffers a run of consecutive whole-line comments while the loader
# decides whether they become a declaration's leading_doc or float as
# their own comment nodes.
#

module Gloo
  module Persist
    class CommentBuffer

      #
      # Set up an empty buffer.
      #
      def initialize
        @pending = []
      end

      #
      # Buffer one comment line. raw is the full source line (minus
      # its trailing newline); tabs is its indentation level.
      #
      def push( raw, tabs )
        @pending << { :raw => raw, :tabs => tabs }
      end

      #
      # Detach the buffered run as floating comment nodes, appended in
      # order to the given children array.
      #
      def flush_into( children )
        return if @pending.empty?

        @pending.each { |c| children << Source::CommentNode.new( c[ :raw ] ) }
        @pending = []
      end

      #
      # If the buffered run sits at the same indent as line_tabs, claim
      # it as a leading_doc (raw, newline-joined) and clear the buffer.
      # Otherwise flush it into children as floating comments first, so
      # document order is kept, and return nil.
      #
      def take_leading_doc( line_tabs, children )
        if !@pending.empty? && @pending.last[ :tabs ] == line_tabs
          doc = @pending.map { |c| c[ :raw ] }.join( "\n" )
          @pending = []
          return doc
        end

        flush_into( children )
        return nil
      end

    end
  end
end
