# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# The concrete source model for one loaded file: an ordered list of
# nodes (comments, blank lines, directives, and object declarations)
# that mirrors what the loader actually read, so a save can rewrite
# the file instead of regenerating it from the heap.
#
# The top level plays the same role as an Source::ObjNode's children
# list -- there is no special "root" wrapper, just the file's own
# ordered content, which may include more than one top-level object
# declaration (a file may legitimately declare several roots).
#

module Gloo
  module Persist
    module Source
      class SourceDoc

        attr_reader :children

        # A file whose last line has no line ending: every node's text
        # ends with one anyway (so new text can follow any node), and
        # the document leaves the last one off.
        attr_accessor :no_final_newline

        #
        # Set up an empty source document.
        #
        def initialize
          @children = []
          @no_final_newline = false
        end

        #
        # The file's exact text: every node's text, in order. Right
        # after a load this is the file, byte for byte.
        #
        def text
          str = @children.map( &:text ).join
          str = str.delete_suffix( "\n" ) if @no_final_newline
          return str
        end

        #
        # Note that the file's last line had no line ending, and give it
        # one in the node that holds it (see no_final_newline).
        #
        def missing_final_newline!
          leaf = last_text_node( @children )
          return unless leaf

          leaf.raw << "\n"
          @no_final_newline = true
        end

        #
        # Every object declaration in the document, at any depth, in
        # file order.
        #
        def obj_nodes( nodes = @children, found = [] )
          nodes.each do |node|
            next unless node.is_a?( Source::ObjNode )

            found << node
            obj_nodes( node.children, found )
          end
          return found
        end

        #
        # The top-level object declarations in this file (usually one,
        # per the "a file owns its declarations" model -- more than one
        # only when the file legitimately declares several roots).
        #
        def roots
          return @children.select { |n| n.is_a?( Source::ObjNode ) }
        end

        #
        # Find and remove the node for the given heap object, searching
        # this document's whole tree (not just the top level) -- used to
        # move a subtree into a different file (see save {obj} to
        # {path}). Returns the removed node, still carrying its own
        # children/leading_doc, or nil if this document has no node for
        # that object (it may be owned by a different file, or never
        # have had a declaration of its own -- eg. a nested-container
        # shorthand's auto-created intermediate).
        #
        def extract( obj )
          return remove_matching( @children, obj )
        end

        private

        #
        # The node whose text comes last in the file: the last node, or
        # its last child (at any depth) if it has children.
        #
        def last_text_node( nodes )
          last = nodes.last
          return nil unless last
          return last unless last.is_a?( Source::ObjNode ) && last.children.any?

          return last_text_node( last.children )
        end

        #
        # Depth-first search of nodes (and their children) for the one
        # linked to obj; removes it from whichever children array it's
        # actually in and returns it.
        #
        def remove_matching( nodes, obj )
          nodes.each do |node|
            next unless node.is_a?( Source::ObjNode )

            if node.obj&.equal?( obj )
              nodes.delete( node )
              return node
            end

            found = remove_matching( node.children, obj )
            return found if found
          end
          return nil
        end

      end
    end
  end
end
