# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Move an object to a new parent.
#

module Gloo
  module Verbs
    class Move < GlooLang::Core::Verb

      KEYWORD = 'move'.freeze
      KEYWORD_SHORT = 'mv'.freeze
      TO = 'to'.freeze
      MISSING_SRC_ERR = 'Object to move was not specified!'.freeze
      MISSING_SRC_OBJ_ERR = 'Could not find object to move: '.freeze
      MISSING_DST_ERR = "Move' must include 'to' parent object!".freeze
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
        pn = GlooLang::Core::Pn.new( @engine, name )
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

        pn = GlooLang::Core::Pn.new( @engine, dst )
        o = pn.resolve
        @engine.err( "#{MISSING_DST_OBJ_ERR} '#{dst}'" ) unless o
        return o
      end

    end
  end
end
