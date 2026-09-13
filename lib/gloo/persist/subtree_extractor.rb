# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Resolves 'save {obj} to {path}' into the Source::ObjNode that should
# be moved into the target file: pulled out of whichever file already
# owns it, or built fresh when obj has no file of its own yet. Does
# not touch disk -- PersistMan wires the result into a new
# FileStorage and drives the actual save (including re-saving the
# file the node was pulled out of).
#

module Gloo
  module Persist
    class SubtreeExtractor

      SPANS_MULTIPLE_FILES_ERR =
        "Can't extract: this object's subtree has declarations in more than one file. " \
        'Save each contributing file on its own first.'.freeze
      NO_OWN_DECLARATION_ERR =
        "Can't extract: this object has no declaration of its own to move " \
        '(it may be an auto-created intermediate container from nested-container ' \
        'shorthand) -- extract a child that does, or a shallower ancestor that does.'.freeze

      #
      # Set up an extractor for the given engine.
      #
      def initialize( engine )
        @engine = engine
      end

      #
      # Resolve obj to the Source::ObjNode that should be written to
      # the new file, with its name set to obj's full dotted path (so
      # the target file recreates any prefix container chain via
      # nested-container shorthand) and its indentation recomputed for
      # life as a fresh top-level declaration.
      #
      # Returns [ node, source_fs ]: source_fs is the FileStorage obj
      # was pulled out of (already updated in memory -- its own save is
      # still the caller's job), or nil when obj had no file of its own
      # to remove from. Returns [ nil, nil ] (having already called
      # engine.err) if extraction isn't possible.
      #
      def extract( obj, maps )
        owners = owning_file_storages( obj, maps )
        return err( SPANS_MULTIPLE_FILES_ERR ) if owners.count > 1

        source_fs = owners.first
        node = source_fs ? remove_node( obj, source_fs ) : fresh_node( obj )
        return err( NO_OWN_DECLARATION_ERR ) unless node

        node.name = dotted_name( obj )
        reindent( node, 0 )
        return [ node, source_fs ]
      end

      private

      #
      # Report the error and return [ nil, nil ], for a one-line call site.
      #
      def err( message )
        @engine.err( message )
        return [ nil, nil ]
      end

      #
      # Every FileStorage whose SourceDoc has a node for obj itself, or
      # for any of its descendants (a namespace pattern applied inside
      # obj's own subtree, not just above it).
      #
      def owning_file_storages( obj, maps )
        subtree = subtree_objects( obj )
        return maps.select { |fs| fs.source_doc && any_node_for?( fs.source_doc.children, subtree ) }
      end

      #
      # obj and every object beneath it in the live heap, as a
      # (compare-by-identity) set membership check.
      #
      def subtree_objects( obj )
        set = {}.compare_by_identity
        set[ obj ] = true
        collect_descendants( obj, set )
        return set
      end

      #
      # Recursively add obj's live children to the set.
      #
      def collect_descendants( obj, set )
        obj.children.each do |child|
          set[ child ] = true
          collect_descendants( child, set )
        end
      end

      #
      # Does any node in this list (or their descendants) belong to an
      # object in the given set?
      #
      def any_node_for?( nodes, set )
        return nodes.any? do |node|
          next false unless node.is_a?( Source::ObjNode )
          next true if node.obj && set.key?( node.obj )

          any_node_for?( node.children, set )
        end
      end

      #
      # obj has no file of its own (never loaded, or created at
      # runtime since) -- build a plain node with no raw text of its
      # own. FileSaver renders it fresh from the live object, the same
      # way it already does for any brand-new child.
      #
      def fresh_node( obj )
        node = Source::ObjNode.new( :name => obj.name, :raw_type => obj.type_display )
        node.obj = obj
        return node
      end

      #
      # Pull obj's node out of the file that owns it. Returns nil if
      # that file turns out to have no node of obj's own to remove (eg.
      # obj is an intermediate container ShorthandExpander created,
      # which never gets a node of its own).
      #
      def remove_node( obj, fs )
        node = fs.source_doc.extract( obj )
        return nil unless node

        fs.drop_root( obj )
        return node
      end

      #
      # obj's full dotted path from its file-owning root down to
      # itself, eg. "app.core.settings" -- how the target file
      # recreates the prefix chain via nested-container shorthand. A
      # plain top-level object's path is just its own name.
      #
      def dotted_name( obj )
        names = [ obj.name ]
        o = obj.parent
        until o.nil? || o.root?
          names.unshift( o.name )
          o = o.parent
        end
        return names.join( '.' )
      end

      #
      # Recompute raw_indent (and, for a BEGIN/END node, raw_end_indent
      # to match) from scratch for the moved node and every descendant
      # ObjNode. Their old indentation depth described nesting inside
      # the file they came from; here obj itself is depth 0, in a
      # brand-new file. Floating trivia (a blank line or comment not
      # attached as some declaration's leading_doc) travels along
      # unindented-adjusted -- purely cosmetic, since indentation never
      # affects how a comment/blank line is recognized on reload.
      #
      def reindent( node, depth )
        new_indent = "\t" * depth
        node.raw_indent = new_indent
        node.raw_end_indent = new_indent if node.block_style == :begin_end
        node.leading_doc = reindent_doc( node.leading_doc, new_indent ) if node.leading_doc
        node.children.each do |child|
          reindent( child, depth + 1 ) if child.is_a?( Source::ObjNode )
        end
      end

      #
      # Re-indent a raw leading_doc's lines to new_indent, replacing
      # whatever leading whitespace each '#'-prefixed line had in the
      # file it came from.
      #
      def reindent_doc( raw, new_indent )
        return raw.split( "\n" ).map { |line| "#{new_indent}#{line.lstrip}" }.join( "\n" )
      end

    end
  end
end
