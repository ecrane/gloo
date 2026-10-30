# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class used to save an object to a file.
#
# Given a Source::SourceDoc (captured at load time), this is a
# rewriter, not a regenerator. Comments, blank lines and directives are
# written back exactly as read. A declaration whose object is still in
# its place is written back exactly too, unless it holds the object's
# value and the value changed: then its head is kept and the value is
# written again. A declaration whose object was deleted or moved away
# is dropped. A new object, or one moved in, is written after the last
# child of its parent's first declaration, in the file's style.
#
# The save builds a new source document for what it writes, so the
# file can be saved again (and checked for changes) the same way.
#
# With no SourceDoc at all (the object was never loaded from a file),
# the file is written from the heap, so saving a brand-new in-memory
# object still works.
#

module Gloo
  module Persist
    class FileSaver

      #
      # Set up a file saver. source_doc is optional -- when given, the
      # save rewrites it; otherwise the file is written from the heap.
      # batch, when given, carries the SaveIndex shared by every file in
      # one save (PersistMan#save_batch builds it); without one, the
      # saver indexes every loaded file itself.
      #
      def initialize( engine, pn, obj, source_doc = nil, batch = nil )
        @engine = engine
        @mech = @engine.platform.get_file_mech( @engine )
        @pn = pn
        @obj = obj
        @source_doc = source_doc
        @index = batch && batch[ :index ]
      end

      #
      # Save the object to the file. Returns the source document for
      # what was written.
      #
      def save
        doc = render
        @mech.write( @pn, doc.text )
        return doc
      end

      #
      # Would saving now actually change anything on disk?
      #
      def dirty?
        return false unless @source_doc

        return render.text != @source_doc.text
      end

      #
      # The text for an object and everything under it, written from
      # scratch in the default style (indent is the depth of its
      # declaration).
      #
      def get_obj( obj, indent = 0 )
        @index = SaveIndex.new( @engine, [] )
        @writer = DeclarationWriter.new( @engine, FileStyle.new( @engine ) )
        @unit = FileStyle::DEFAULT_UNIT
        return unplaced( obj, FileStyle::DEFAULT_UNIT * indent ).text
      end

      #
      # A source node for an object and everything under it, written
      # from scratch in the default style, at the top of a file, with
      # the given name (a dotted path when it's written into a file of
      # its own).
      #
      def new_node( obj, name = obj.name )
        @index = SaveIndex.new( @engine, [] )
        @writer = DeclarationWriter.new( @engine, FileStyle.new( @engine ) )
        @unit = FileStyle::DEFAULT_UNIT
        @index.claim( obj )
        return unplaced( obj, '', name )
      end

      #
      # The source document for what a save would write.
      #
      def render
        return regenerate unless @source_doc

        @index ||= SaveIndex.new( @engine, @engine.persist_man.maps )
        style = FileStyle.new( @engine, @source_doc )
        @writer = DeclarationWriter.new( @engine, style )
        @unit = style.unit
        doc = Source::SourceDoc.new
        doc.no_final_newline = @source_doc.no_final_newline
        render_nodes( @source_doc.children, doc.children )
        return doc
      end

      private

      #
      # A document for a file written from scratch: the object and
      # everything under it.
      #
      def regenerate
        doc = Source::SourceDoc.new
        doc.children << new_node( @obj )
        return doc
      end

      #
      # Write one level of source nodes into out: comments, blank lines
      # and directives as they are; each standing declaration (with
      # anything new under it); and after a dotted declaration, any new
      # children of the containers it names.
      #
      def render_nodes( nodes, out )
        nodes.each do |node|
          unless node.is_a?( Source::ObjNode )
            out << node
            next
          end
          next unless @index.standing?( node )

          out << render_obj_node( node )
          @index.shorthand_targets( node ).each do |parent, prefix|
            @index.unplaced_children( parent ).each do |child|
              out << unplaced( child, node.raw_indent, "#{prefix}.#{child.name}" )
            end
          end
        end
      end

      #
      # One standing declaration: written as it was unless it holds a
      # value that changed; its children the same way; then, if this is
      # where its object's new children go, those.
      #
      def render_obj_node( node )
        copy = node.detached( own_text( node ) )
        render_nodes( node.children, copy.children )
        return copy unless node.obj && writes_children_of?( node )

        indent = child_indent( copy )
        at = after_last_declaration( copy.children )
        @index.unplaced_children( node.obj ).each do |child|
          copy.children.insert( at, unplaced( child, indent ) )
          at += 1
        end
        return copy
      end

      #
      # Where a new child goes in a list of nodes: after the last
      # declaration, ahead of any comments and blank lines that follow
      # it (they lead into what comes next).
      #
      def after_last_declaration( nodes )
        last = nodes.rindex { |n| n.is_a?( Source::ObjNode ) }
        return last ? last + 1 : 0
      end

      #
      # The declaration's own text: as read (with any head gloo had to
      # guess at written as understood), or written again if it holds
      # its object's value and the value changed.
      #
      def own_text( node )
        fixed = node.repaired
        return fixed.raw unless node.obj && @index.holder?( node ) && node.changed?

        return @writer.changed_text( fixed )
      end

      #
      # Is this declaration where its object's new children are written?
      #
      def writes_children_of?( node )
        fs, target, prefix = @index.writer_for( node.obj )
        return fs&.source_doc.equal?( @source_doc ) && target.equal?( node ) && prefix.nil?
      end

      #
      # The indentation for a new child of a declaration: its last
      # child's, or one step in from it.
      #
      def child_indent( node )
        last = node.children.reverse.find { |c| c.is_a?( Source::ObjNode ) }
        return last ? last.raw_indent : "#{node.raw_indent}#{@unit}"
      end

      #
      # A node for an object no standing declaration places, and
      # everything under it: a moved object keeps its first declaration
      # (and doc) at the new indentation; a new one is written from
      # scratch. name is how it's written (a dotted path for a shorthand
      # line).
      #
      def unplaced( obj, indent, name = obj.name )
        node = moved_node( obj, indent, name ) || @writer.new_node( obj, indent, name )
        obj.children.each do |child|
          next if @index.placed?( child ) || !@index.claim( child )

          node.children << unplaced( child, "#{indent}#{@unit}" )
        end
        return node
      end

      #
      # The first declaration of a moved object, at its new place.
      #
      def moved_node( obj, indent, name )
        _fs, first = @index.entries_for( obj ).first
        return nil unless first

        node = first.detached( first.changed? ? @writer.changed_text( first ) : first.raw )
        node.rename( name ) unless name == node.name
        node.reindent( indent )
        return node
      end

    end
  end
end
