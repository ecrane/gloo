# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class takes an object and writes it to a file.
#

module GlooLang
  module Persist
    class FileStorage

      attr_reader :obj, :pn

      #
      # Set up a file storage for an object.
      #
      def initialize( engine, pn, obj = nil )
        @engine = engine
        @obj = obj
        @pn = pn
      end

      #
      # Save the object to the file.
      #
      def save
        fs = FileSaver.new( @engine, @pn, @obj )
        fs.save
      end

      #
      # Load the object from the file.
      #
      def load
        fl = FileLoader.new( @engine, @pn )
        fl.load
        @obj = fl.obj
        if @obj
          @engine.log.debug "Loaded object: #{@obj.name}"
        else
          @engine.log.error "Error loading file at #{@pn}"
        end
      end

    end
  end
end
