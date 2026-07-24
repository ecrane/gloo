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
      MISSING_SRC_OBJ_ERR = 'Could not find object to move: '.freeze
      MISSING_DST_ERR = "'Move' must include 'to' parent object!".freeze
      MISSING_DST_OBJ_ERR = 'Could not resolve target: '.freeze

      #
      # Run the verb.
      #
      def run
        dst = lookup_dst
        return if dst.nil?

        o = lookup_obj
        return unless o

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
      # Lookup the object that we're moving.
      #
      def lookup_obj
        arr = @tokens.before_token( TO )
        if arr.count == 1
          @engine.err MISSING_SRC_ERR
          return
        end

        name = arr[ 1 ]
        pn = Gloo::Core::Pn.new( @engine, name )
        o = pn.resolve

        @engine.err( "#{MISSING_SRC_OBJ_ERR} #{name}" ) unless o
        return o
      end

      #
      # Lookup destination, the new parent object.
      #
      def lookup_dst
        dst = @tokens.after_token( TO )
        unless dst
          @engine.err MISSING_DST_ERR
          return nil
        end

        pn = Gloo::Core::Pn.new( @engine, dst )
        o = pn.resolve
        @engine.err( "#{MISSING_DST_OBJ_ERR} '#{dst}'" ) unless o
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
          :description => 'Move an object to a new parent.',
          :syntax => [ 'move {path.to.object} to {new.parent}' ],
          :parameters => [
            '{path.to.object} — The object that we want to move.',
            '{new.parent} — The new location for the object.'
          ],
          :result => 'The object will now be in the new location.',
          :errors => [
            "#{MISSING_SRC_ERR} The {path.to.object} is not specified.",
            "#{MISSING_SRC_OBJ_ERR}{path.to.object} — The {path.to.object} cannot be resolved.",
            "#{MISSING_DST_ERR} The {new.parent} is not specified.",
            "#{MISSING_DST_OBJ_ERR}{new.parent} — The {new.parent} cannot be resolved."
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
