# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class used to save an object to a file.
#
# Given a Source::SourceDoc (captured at load time), this is a
# rewriter, not a regenerator: trivia (comments, blank lines,
# directives) is emitted verbatim, and a declaration's raw text is
# kept as-is unless the live object's value has actually changed --
# only then is the value re-rendered, via the object's own
# serialize_value. Deleted objects drop out; objects created since
# load are rendered fresh and appended.
#
# With no SourceDoc at all (the object was never loaded from a file),
# this falls back to plain regeneration from the heap, so saving a
# brand-new in-memory object still works.
#

module Gloo
  module Persist
    class FileSaver

      #
      # Set up a file saver. source_doc is optional -- when given, the
      # save rewrites it in place; otherwise the file is regenerated
      # from the heap.
      #
      def initialize( engine, pn, obj, source_doc = nil )
        @engine = engine
        @mech = @engine.platform.get_file_mech( @engine )
        @pn = pn
        @obj = obj
        @source_doc = source_doc
      end

      #
      # Save the object to the file.
      #
      def save
        data = @source_doc ? rewrite : regenerate
        @mech.write( @pn, data )
      end

      #
      # Get string of tabs for indentation.
      #
      def tabs( indent = 0 )
        return "\t" * indent
      end

      #
      # Convert an object to textual representation from scratch, with
      # no source text to preserve. This is a recursive function, and
      # is also reused by the rewriter for any object created since
      # load (which has no source node of its own to rewrite).
      #
      def get_obj( obj, indent = 0 )
        t = tabs( indent )
        str = "#{t}#{obj.name} [#{obj.type_display}]#{obj.serialize_value( indent )}\n"
        obj.children.each do |child|
          str << get_obj( child, indent + 1 )
        end
        return str
      end

      private

      #
      # Regenerate the whole file from the heap (the pre-Source::SourceDoc
      # behavior), used when there's no source text to rewrite.
      #
      def regenerate
        return get_obj( @obj )
      end

      # ---------------------------------------------------------------------
      #    Rewrite (Source::SourceDoc-driven)
      # ---------------------------------------------------------------------

      #
      # Rewrite the file from its source document: known declarations
      # are patched in place, deleted ones dropped, and anything new
      # appended.
      #
      def rewrite
        return render_children( @source_doc.children, @engine.heap.root, 0 )
      end

      #
      # Render one level of source nodes against the live children of
      # live_parent: trivia passes through untouched; a declaration
      # whose object is still present is patched in place; one whose
      # object is gone is dropped; anything in live_parent.children
      # with no matching source node is new and gets rendered fresh.
      #
      def render_children( nodes, live_parent, indent )
        str = ''
        seen = []
        nodes.each do |node|
          if node.is_a?( Source::ObjNode )
            next unless node.obj && live_parent.children.include?( node.obj )

            seen << node.obj
            str << render_obj_node( node, indent )
          else
            str << render_trivia( node )
          end
        end

        ( live_parent.children - seen ).each { |child| str << get_obj( child, indent ) }
        return str
      end

      #
      # A comment, blank line, or top-of-file directive -- passed
      # through exactly as read.
      #
      def render_trivia( node )
        return "#{node.raw}\n"
      end

      #
      # One declaration whose object is still live: its leading_doc (if
      # any) and its own line are kept (name/type/indent never change
      # once declared), its value is kept raw or re-rendered depending
      # on whether it changed, and its children are rewritten the same
      # way, one level deeper.
      #
      def render_obj_node( node, indent )
        str = node.leading_doc ? "#{node.leading_doc}\n" : ''
        str << "#{node.raw_indent}#{node.name} [#{node.raw_type}]#{declaration_tail( node, indent )}\n"
        str << render_children( node.children, node.obj, indent + 1 )
        return str
      end

      #
      # The text that follows "name [type]" on the declaration line:
      # the raw source, unless the live value no longer matches it.
      #
      def declaration_tail( node, indent )
        return raw_declaration_tail( node ) if value_unchanged?( node )

        return node.obj.serialize_value( indent )
      end

      #
      # Reproduce the original declaration's value text exactly as it
      # was read. raw_tail is the declaration line's own exact tail
      # (eg. " : BEGIN" or " :"); a begin_end/body style has further
      # raw content following it.
      #
      def raw_declaration_tail( node )
        case node.block_style
        when :begin_end
          return "#{node.raw_tail}\n#{node.raw_value}#{node.raw_end_indent}END"
        when :body
          return node.raw_value.to_s.empty? ? node.raw_tail : "#{node.raw_tail}\n#{node.raw_value}"
        else
          return node.raw_tail
        end
      end

      # ---------------------------------------------------------------------
      #    Has the value actually changed since load?
      # ---------------------------------------------------------------------

      #
      # Does the live object's value still match what raw_value would
      # produce? A script body is compared line by line (raw comments
      # excluded, since they were never run); everything else is
      # compared by re-running the raw text through the same set_value
      # conversion the loader used, and comparing the result.
      #
      def value_unchanged?( node )
        return false unless node.obj
        return body_value_unchanged?( node ) if node.block_style == :body

        trial = node.obj.class.new( @engine )
        trial.set_value( node.raw_value )
        return trial.value == node.obj.value
      rescue
        return false
      end

      #
      # A script body's raw text, minus its comment lines (never
      # executed) and with each line stripped, should equal the live
      # object's own command lines.
      #
      def body_value_unchanged?( node )
        raw_lines = node.raw_value.to_s.split( "\n" )
        executable = raw_lines.reject { |l| l.strip.start_with?( '#' ) }.map( &:strip )
        return executable == current_script_lines( node.obj )
      end

      #
      # The live object's command lines, whatever form its value is
      # currently in.
      #
      def current_script_lines( obj )
        return obj.value if obj.value_is_array?
        return [] if obj.value_is_blank?

        return [ obj.value.to_s.strip ]
      end

    end
  end
end
