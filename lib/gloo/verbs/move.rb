# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Move an object to a new parent.
#

module Gloo
  module Verbs
    class Move < Gloo::Core::Verb

      KEYWORD = 'move'.freeze
      KEYWORD_SHORT = 'mv'.freeze
      TO = 'to'.freeze
      MISSING_SRC_ERR = 'Object to move was not specified!'.freeze
      MISSING_DST_ERR = "'Move' must include 'to' parent object!".freeze
      NAME_TAKEN_ERR = "Could not move '%s': '%s' already has a child named '%s'.".freeze
      INSIDE_ITSELF_ERR = "Could not move '%s': it can't go inside itself.".freeze

      #
      # Run the verb.
      # A name is unique in its container, so an object can't move into
      # one that already has a child with its name; nor can it move
      # inside itself. Moving it to the parent it's already in does
      # nothing.
      #
      def run
        dst = lookup_dst
        return if dst.nil?

        o = lookup_obj
        return unless o
        return if dst.equal?( o.parent )
        return refuse( format( INSIDE_ITSELF_ERR, o.pn ) ) if inside?( dst, o )
        return refuse( format( NAME_TAKEN_ERR, o.pn, dst.pn, o.name ) ) if dst.contains_child?( o.name )

        o.parent.remove_child o
        dst.add_child o
      end

      #
      # Get the Verb's keyword.
      #
      def self.keyword
        return KEYWORD
      end

      #
      # Get the Verb's keyword shortcut.
      #
      def self.keyword_shortcut
        return KEYWORD_SHORT
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Report why the object can't be moved; nothing moves, and it is
      # false.
      #
      def refuse( msg )
        @engine.err msg
        @engine.heap.it.set_to false
      end

      #
      # Is dst the object itself, or somewhere under it?
      #
      def inside?( dst, obj )
        o = dst
        while o
          return true if o.equal?( obj )

          o = o.parent
        end
        return false
      end

      #
      # Lookup the object that we're moving.
      #
      def lookup_obj
        arr = @tokens.before_token( TO )
        if arr.count == 1
          @engine.syntax_err MISSING_SRC_ERR
          return
        end

        name = arr[ 1 ]
        pn = Gloo::Core::Pn.new( @engine, name )
        return nil if pn.it_target_err?( 'moved' )

        o = pn.resolve

        @engine.err( Gloo::Core::NotFound.object( name ) ) unless o
        return o
      end

      #
      # Lookup destination, the new parent object.
      #
      def lookup_dst
        dst = @tokens.after_token( TO )
        unless dst
          @engine.syntax_err MISSING_DST_ERR
          return nil
        end

        pn = Gloo::Core::Pn.new( @engine, dst )
        return nil if pn.it_target_err?( 'moved into' )

        o = pn.resolve
        @engine.err( Gloo::Core::NotFound.object( dst ) ) unless o
        return o
      end

      # ---------------------------------------------------------------------
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Move an object to a new parent. A name is unique ' \
            'in its container, so the new parent must not already have a ' \
            'child with the same name.',
          :syntax => [ 'move {path.to.object} to {new.parent}' ],
          :parameters => [
            '{path.to.object} — The object that we want to move.',
            '{new.parent} — The new location for the object.'
          ],
          :result => 'The object will now be in the new location. Moving it ' \
            'to the parent it is already in does nothing. A pure action: it ' \
            'is left alone, unless the move is refused.',
          :errors => [
            "#{MISSING_SRC_ERR} The {path.to.object} is not specified.",
            "Object '{path.to.object}' was not found. — The {path.to.object} cannot be resolved.",
            "#{MISSING_DST_ERR} The {new.parent} is not specified.",
            "Object '{new.parent}' was not found. — The {new.parent} cannot be resolved.",
            "#{format( NAME_TAKEN_ERR, '{path.to.object}', '{new.parent}', '{name}' )} — " \
              'The new parent already has a child with that name. Nothing moves, and it is false.',
            "#{format( INSIDE_ITSELF_ERR, '{path.to.object}' )} — The new parent is the " \
              'object itself or something under it. Nothing moves, and it is false.'
          ],
          :examples => <<~EXAMPLES.strip
            can [can] :
              two [string] : def
              data [can] :
                one [string] : abc
              on_load [script] :
                move can.two to can.data
          EXAMPLES
        }
      end

    end
  end
end
