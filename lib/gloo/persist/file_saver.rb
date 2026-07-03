# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Helper class used to save an object to a file..
#

module Gloo
  module Persist
    class FileSaver

      #
      # Set up a file storage for an object.
      #
      def initialize( engine, pn, obj )
        @engine = engine
        @mech = @engine.platform.get_file_mech( @engine )
        @pn = pn
        @obj = obj
      end

      #
      # Save the object to the file.
      #
      def save
        data = get_obj( @obj )
        @mech.write( @pn, data )
      end

      #
      # Get string of tabs for indentation.
      #
      def tabs( indent = 0 )
        return "\t" * indent
      end

      #
      # Convert an object to textual representation.
      # This is a recursive function.
      #
      def get_obj( obj, indent = 0 )
        t = tabs( indent )
        str = "#{t}#{obj.name} [#{obj.type_display}] : #{obj.value_display}\n"
        obj.children.each do |child|
          str << get_obj( child, indent + 1 )
        end
        return str
      end

    end
  end
end
