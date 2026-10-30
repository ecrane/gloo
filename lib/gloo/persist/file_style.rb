# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# How a file is written, learned from its source: the indentation it
# steps in by, and how it spells each type. A save writes new text the
# same way, so a 2-space file full of [int] and [can] gets 2 spaces,
# [int] and [can] back. A new file, or one with nothing to learn from,
# gets 2 spaces and each type's own name.
#

module Gloo
  module Persist
    class FileStyle

      DEFAULT_UNIT = '  '.freeze

      attr_reader :unit

      #
      # Learn the style of a source document (nil for a new file).
      #
      def initialize( engine, source_doc = nil )
        @engine = engine
        @unit = DEFAULT_UNIT
        @spellings = {}
        learn( source_doc ) if source_doc
      end

      #
      # How to write an object's type: the spelling the file uses most
      # for that type, or the type's own name. nil means the file writes
      # it with no brackets at all (an untyped 'name : value').
      #
      def type_for( obj )
        return @spellings.fetch( obj.class ) { obj.type_display }
      end

      private

      #
      # Read the unit and the type spellings from the document.
      #
      def learn( source_doc )
        learn_unit( source_doc.children )
        counts = Hash.new { |h, k| h[ k ] = Hash.new( 0 ) }
        source_doc.obj_nodes.each do |node|
          type = type_class( node )
          counts[ type ][ spelling( node ) ] += 1 if type
        end
        counts.each { |type, spelled| @spellings[ type ] = spelled.max_by { |_, n| n }.first }
      end

      #
      # The step in from a top-level declaration to its first child.
      #
      def learn_unit( nodes )
        nodes.each do |node|
          next unless node.is_a?( Source::ObjNode )

          child = node.children.find { |c| c.is_a?( Source::ObjNode ) }
          next unless child

          step = child.raw_indent.delete_prefix( node.raw_indent )
          @unit = step unless step.empty?
          return
        end
      end

      #
      # The object type class a declaration was written with (nil for a
      # type gloo doesn't know, which tells us nothing).
      #
      def type_class( node )
        return @engine.dictionary.find_obj( node.raw_type.to_s )
      end

      #
      # How the declaration spells its type: the text in its brackets,
      # or nil when it has none.
      #
      def spelling( node )
        return nil unless node.head.include?( '[' )

        return node.raw_type
      end

    end
  end
end
