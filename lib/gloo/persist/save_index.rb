# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# What every loaded file declares, for one save: which declarations
# name each object (one object can be declared on several lines, in
# one file or several), which of them still stand, and where an object
# no declaration places (new, or moved) should be written.
#
# A declaration stands if its object is still under the parent it was
# loaded under, and the declaration it sits under stands too. The
# first declaration of an object (in load order) holds its value.
#

module Gloo
  module Persist
    class SaveIndex

      #
      # Index the source documents of the given file storages, in load
      # order.
      #
      def initialize( engine, storages )
        @engine = engine
        @entries = {}.compare_by_identity
        @standing = {}.compare_by_identity
        @claimed = {}.compare_by_identity
        @targets = {}.compare_by_identity
        @in_order = []
        @implied = {}.compare_by_identity
        @members = {}.compare_by_identity
        storages.each do |fs|
          walk( fs, fs.source_doc.children, true, @engine.heap.root ) if fs.source_doc
        end
        find_shorthand_targets
      end

      #
      # Does the declaration still stand (it's written back in its
      # file)?
      #
      def standing?( node )
        return @standing.fetch( node, false )
      end

      #
      # Does the declaration hold its object's value (it's the first one
      # that names the object)?
      #
      def holder?( node )
        first = @entries[ node.obj ]&.first
        return first ? first[ 1 ].equal?( node ) : true
      end

      #
      # The declarations of an object, in load order, as [ fs, node ].
      #
      def entries_for( obj )
        return @entries.fetch( obj, [] )
      end

      #
      # Does some standing declaration place the object: its own, or a
      # dotted one that names it on the way to its object?
      #
      def placed?( obj )
        return declared?( obj ) || @implied.key?( obj )
      end

      #
      # Does a standing declaration of the object's own place it?
      #
      def declared?( obj )
        return entries_for( obj ).any? { |_, node| standing?( node ) }
      end

      #
      # Where a new or moved child of parent is written:
      # [ fs, node, nil ] -- under that declaration of parent, after its
      # last child; [ fs, node, prefix ] -- as a shorthand line after
      # that dotted declaration, named prefix.child; or nil when no file
      # takes it (a new root-level object isn't added to a file).
      #
      def writer_for( parent )
        return nil if parent.nil? || parent.root?

        fs, node = entries_for( parent ).find { |_, n| standing?( n ) }
        return [ fs, node, nil ] if node

        return @targets[ parent ]
      end

      #
      # The intermediate containers a dotted declaration writes new
      # children for, as [ parent, prefix ].
      #
      def shorthand_targets( node )
        return @targets.select { |_, t| t[ 1 ].equal?( node ) }.map { |parent, t| [ parent, t[ 2 ] ] }
      end

      #
      # Claim an object for writing in this save; false if a file
      # already wrote it.
      #
      def claim( obj )
        return false if @claimed.key?( obj )

        @claimed[ obj ] = true
        return true
      end

      #
      # The children of parent that no standing declaration places (new,
      # or moved in), claimed for writing.
      #
      def unplaced_children( parent )
        return parent.children.select { |c| !placed?( c ) && claim( c ) }
      end

      private

      #
      # Record the declarations in a list of source nodes. container is
      # the object the list's declarations are under (the heap root at
      # the top of a file).
      #
      def walk( fs, nodes, parent_standing, container )
        nodes.each do |node|
          next unless node.is_a?( Source::ObjNode )

          stands = parent_standing && stands_alone?( node, container )
          @standing[ node ] = stands
          @in_order << [ fs, node ]
          ( @entries[ node.obj ] ||= [] ) << [ fs, node ] if node.obj
          walk( fs, node.children, stands, node.obj || container )
        end
      end

      #
      # Is a declaration's object where the declaration puts it: under
      # its parent as loaded, and -- for a dotted (shorthand) name --
      # reached from container by that path? A line gloo couldn't make
      # an object for is always kept.
      #
      def stands_alone?( node, container )
        return true unless node.obj
        return false unless node.obj.parent.equal?( node.home ) && child_of?( node.obj, node.home )

        segments = node.name.split( '.' )
        return true if segments.size == 1

        o = node.obj.parent
        segments[ 0..-2 ].reverse.each do |seg|
          return false unless o && o.name.casecmp?( seg ) && child_of?( o, o.parent )

          o = o.parent
        end
        return o.equal?( container )
      end

      #
      # Is child one of parent's children (by identity)? Each parent's
      # children are gathered once, so a big container stays quick.
      #
      def child_of?( child, parent )
        return false unless parent

        unless @members.key?( parent )
          set = {}.compare_by_identity
          parent.children.each { |c| set[ c ] = true }
          @members[ parent ] = set
        end
        return @members[ parent ].key?( child )
      end

      #
      # For each container that only exists through dotted names (it has
      # no declaration of its own), the shorthand line new children go
      # after: the last one through it, in the first file that has one.
      #
      def find_shorthand_targets
        @in_order.each do |fs, node|
          next unless node.obj && standing?( node ) && node.name.include?( '.' )

          intermediates( node ).each do |parent, prefix|
            next if declared?( parent )

            @implied[ parent ] = true
            target = @targets[ parent ]
            @targets[ parent ] = [ fs, node, prefix ] if target.nil? || target[ 0 ].equal?( fs )
          end
        end
      end

      #
      # The containers a dotted declaration names on its way to its
      # object, as [ container, dotted path to it ].
      #
      def intermediates( node )
        segments = node.name.split( '.' )
        found = []
        o = node.obj.parent
        ( segments.size - 1 ).downto( 1 ) do |i|
          found.unshift( [ o, segments[ 0, i ].join( '.' ) ] )
          o = o.parent
        end
        return found
      end

    end
  end
end
