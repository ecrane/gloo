# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object path name.
# Path and name elements are separated by periods.
#

module Gloo
  module Core
    class Pn < Baseo

      ROOT = 'root'.freeze
      IT = 'it'.freeze
      ERROR = 'error'.freeze

      attr_reader :src, :elements

      # Set up the object given a source string,
      # ie: the full path and name.
      def initialize( src )
        set_to src
      end

      # Reference to the root object path.
      def self.root
        return Pn.new( ROOT )
      end

      # Reference to it.
      def self.it
        return Pn.new( IT )
      end

      # Reference to the error message.
      def self.error
        return Pn.new( ERROR )
      end

      # Does the pathname reference refer to the root?
      def is_root?
        return @src.downcase == ROOT
      end

      # Does the pathname reference refer to it?
      def is_it?
        return @src.downcase == IT
      end

      # Does the pathname reference refer to error?
      def is_error?
        return @src.downcase == ERROR
      end

      # Does the pathname reference refer to the gloo system object?
      def is_gloo_sys?
        return false unless @elements&.count&.positive?

        o = @elements.first.downcase
        return true if o == Gloo::Core::GlooSystem.typename
        return true if o == Gloo::Core::GlooSystem.short_typename

        return false
      end

      # Get the string representation of the pathname.
      def to_s
        return @src
      end

      # Set the object pathname to the given value.
      def set_to( value )
        @src = value.strip unless value.nil?
        @elements = @src.nil? ? [] : @src.split( '.' )
      end

      # Convert the raw string to a list of segments.
      def segments
        return @elements
      end

      # Get the name element.
      def name
        return '' unless self.has_name?

        return @elements.last
      end

      # Does the value include path elements?
      def has_name?
        return @elements.count.positive?
      end

      # Does the value include a name?
      def has_path?
        return @elements.count > 1
      end

      # Get the parent that contains the object referenced.
      def get_parent
        o = $engine.heap.root

        if self.has_path?
          @elements[0..-2].each do |e|
            o = o.find_child( e )
            if o.nil?
              $log.error "Object '#{e}' was not found."
              return nil
            end
          end
        end

        return o
      end

      # Does the object at the path exist?
      def exists?
        return true if self.is_root?
        return true if self.is_it?
        return true if self.is_error?

        parent = self.get_parent
        return false unless parent

        return parent.has_child? name
      end

      # Is the reference to a color?
      def is_color?
        colors = %w[red blue green white black yellow]
        return true if colors.include?( @src.downcase )
      end

      # Resolve the pathname reference.
      # Find the object referenced or return nil if it is not found.
      def resolve
        return $engine.heap.root if self.is_root?
        return $engine.heap.it if self.is_it?
        return $engine.heap.it.error if self.is_error?
        return Gloo::Core::GlooSystem.new( self ) if self.is_gloo_sys?

        parent = self.get_parent
        return nil unless parent

        return parent.find_child( self.name )
      end

    end
  end
end
