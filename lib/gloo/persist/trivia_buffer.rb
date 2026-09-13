# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Buffers a run of comment and blank lines while the loader decides
# where they actually belong -- both what becomes a following
# declaration's leading_doc, and which source node's children array
# floating trivia lands in.
#
# Both kinds are held here (not placed immediately) because a
# declaration only becomes a parent -- and its Source::ObjNode only
# gets pushed as the current node -- once IndentStack#place sees a
# genuinely deeper line follow it (see IndentStack). A blank or
# comment line between a container's declaration and its first child
# arrives *before* that push happens; placing it immediately would
# attach it one level too shallow. Buffering defers the decision until
# take_leading_doc/flush_into is called against the *correct*,
# already-placed node.
#

module Gloo
  module Persist
    class TriviaBuffer

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
      def push_comment( raw, tabs )
        @pending << { :kind => :comment, :raw => raw, :tabs => tabs }
      end

      #
      # Buffer one blank line. raw is its exact source text (may be
      # non-empty if it had trailing whitespace) -- a blank line always
      # breaks a comment run's association with whatever declaration
      # follows, the same as it always has.
      #
      def push_blank( raw )
        @pending << { :kind => :blank, :raw => raw }
      end

      #
      # Detach the whole buffered run -- comments and blanks, in
      # original order -- as floating nodes appended to the given
      # children array.
      #
      def flush_into( children )
        return if @pending.empty?

        flush_list( @pending, children )
        @pending = []
      end

      #
      # If the run since the last blank (or the whole run, if it has no
      # blank in it) is one or more comment lines all at the same
      # indent as line_tabs, claim it as a leading_doc (raw,
      # newline-joined). Anything before that -- an earlier blank, and
      # whatever preceded it -- floats into children first, in order,
      # since a blank always breaks the association. If the trailing
      # run doesn't qualify (wrong indent, or empty), it floats into
      # children too and this returns nil. Either way the buffer is
      # empty afterward.
      #
      def take_leading_doc( line_tabs, children )
        before, after = split_at_last_blank
        flush_list( before, children )

        if after.any? && after.last[ :tabs ] == line_tabs
          doc = after.map { |t| t[ :raw ] }.join( "\n" )
          @pending = []
          return doc
        end

        flush_list( after, children )
        @pending = []
        return nil
      end

      private

      #
      # Split the pending run at its last blank line: everything up to
      # and including it, and everything after (always comments only,
      # by construction -- there's no later blank to have split on).
      # With no blank at all, everything is "after".
      #
      def split_at_last_blank
        idx = @pending.rindex { |t| t[ :kind ] == :blank }
        return [ [], @pending ] unless idx

        return [ @pending[ 0..idx ], @pending[ idx + 1.. ] ]
      end

      #
      # Append each pending entry's node, in order, to children.
      #
      def flush_list( list, children )
        list.each { |t| children << node_for( t ) }
      end

      #
      # The source node one pending entry becomes when it floats.
      #
      def node_for( t )
        return Source::BlankNode.new( t[ :raw ] ) if t[ :kind ] == :blank

        return Source::CommentNode.new( t[ :raw ] )
      end

    end
  end
end
