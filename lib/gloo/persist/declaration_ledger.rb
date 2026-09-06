# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Tracks what a single file declares as it loads: its top-level
# objects (for save resolution), and every object it created -- so a
# re-declaration of a name an earlier file already used can be
# flagged, since in that case the second value is silently dropped.
#

module Gloo
  module Persist
    class DeclarationLedger

      attr_reader :roots

      #
      # Set up a ledger for the file at pn.
      #
      def initialize( engine, pn )
        @engine = engine
        @pn = pn
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
      # `value`. If another file created it and the values differ, the
      # new value is being ignored -- warn so it isn't a surprise. A
      # duplicate name inside one file is left alone (a documented
      # "first one wins").
      #
      def clash( prior, name, value )
        return if @mine.key?( prior )
        return if value.nil? || value.to_s.strip.empty?
        return if prior.value.to_s == value.to_s

        @engine.log.warn(
          "#{@pn}: '#{name}' is already declared in another loaded file with a " \
          "different value (#{prior.value.inspect} kept, #{value.inspect} ignored)."
        )
      end

    end
  end
end
