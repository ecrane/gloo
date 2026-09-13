# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class takes an object and writes it to a file.
#

module Gloo
  module Persist
    class FileStorage

      attr_reader :obj, :pn, :roots, :source_doc

      #
      # Set up a file storage for an object. source_doc is optional --
      # pass one already built (eg. a subtree just extracted into this
      # file by save {obj} to {path}) so this file's saves rewrite it
      # in place instead of falling back to plain regeneration; a
      # bare/never-loaded FileStorage leaves it nil.
      #
      def initialize( engine, pn, obj = nil, source_doc = nil )
        @engine = engine
        @obj = obj
        @pn = pn
        @roots = obj ? [ obj ] : []
        @source_doc = source_doc
      end

      #
      # Save the object to the file. batch, when given, lets a
      # multi-file namespace round-trip -- see PersistMan#save_batch and
      # FileSaver.
      #
      def save( batch = nil )
        fs = FileSaver.new( @engine, @pn, @obj, @source_doc, batch )
        fs.save
      end

      #
      # This file no longer owns obj as one of its roots -- eg. it was
      # just extracted into a different file via save {obj} to {path}.
      # Drops it from roots, and re-points the file's primary obj at
      # whatever root remains (nil if none left), so a later
      # single-object reload/save doesn't act on a root that's moved
      # elsewhere.
      #
      def drop_root( obj )
        @roots.delete( obj )
        @obj = @roots.first if @obj&.equal?( obj )
      end

      #
      # Load the object from the file.
      #
      def load
        fl = FileLoader.new( @engine, @pn )
        fl.load
        @obj = fl.obj
        @roots = fl.roots
        @source_doc = fl.source_doc
        if @obj
          @engine.log.debug "Loaded object: #{@obj.name}"
        else
          @engine.err "Error loading file at #{@pn}"
        end
      end

    end
  end
end
