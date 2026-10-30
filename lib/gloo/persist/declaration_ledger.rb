# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Tracks what a single file declares as it loads: its top-level
# objects (for save resolution), and every object it created -- so a
# re-declaration of a name already used, in an earlier file or earlier
# in this one, can be flagged when its value is ignored.
#

module Gloo
  module Persist
    class DeclarationLedger

      attr_reader :roots

      #
      # Set up a ledger for one file's load.
      #
      def initialize( engine )
        @engine = engine
        @roots = []
        @mine = {}.compare_by_identity
      end

      #
      # Record a top-level object this file created or reused (shorthand
      # lines can re-introduce the same root, so dedupe).
      #
      def root( obj )
        @roots << obj unless @roots.include?( obj )
      end

      #
      # Record an object this file created, at any level.
      #
      def created( obj )
        @mine[ obj ] = true
      end

      #
      # `prior` already existed when this file declared `name` with
      # `value`: the line names the same object, and its value is
      # ignored (the first declaration wins). When the ignored value is
      # different, warn so it isn't a surprise -- whether the first
      # declaration was in another file or earlier in this one. The
      # warning's location (this file and line) comes from the load.
      #
      def clash( prior, name, value )
        return if value.nil? || value.to_s.strip.empty?
        return if prior.value.to_s == value.to_s

        where = @mine.key?( prior ) ? 'above' : 'in another loaded file'
        @engine.warn(
          "'#{name}' is already declared #{where} with a " \
          "different value (#{prior.value.inspect} kept, #{value.inspect} ignored)."
        )
      end

    end
  end
end
