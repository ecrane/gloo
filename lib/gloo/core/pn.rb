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
      CONTEXT = '@'.freeze
      NAMED_COLORS = %w[red blue green white black yellow].freeze
      IT_NOT_AN_OBJECT = "it isn't an object and can't be %s; %s.".freeze
      IT_HINT = 'put it into an object first (put it into x)'.freeze

      attr_reader :src, :elements

      #
      # Set up the object given a source string,
      # ie: the full path and name.
      #
      def initialize( engine, src )
        @engine = engine
        set_to src
      end

      #
      # Reference to the root object path.
      #
      def self.root( engine )
        return Pn.new( engine, ROOT )
      end

      #
      # Reference to it.
      #
      def self.it( engine )
        return Pn.new( engine, IT )
      end

      #
      # Reference to the error message.
      #
      def self.error( engine )
        return Pn.new( engine, ERROR )
      end

      #
      # Does the pathname reference refer to the root?
      #
      def root?
        return @src.downcase == ROOT
      end

      #
      # Does the pathname reference refer to it?
      #
      def it?
        return @src.downcase == IT
      end

      #
      # it is a read-only result value, not an object, so it can't
      # be the target of a verb or message. If the path refers to it,
      # report that (what it can't be: 'sent messages', 'run', ...,
      # and what to do instead) and return true.
      #
      def it_target_err?( what, hint = IT_HINT )
        return false unless self.it?

        @engine.err format( IT_NOT_AN_OBJECT, what, hint )
        return true
      end

      #
      # Does the pathname reference refer to error?
      #
      def error?
        return @src.downcase == ERROR
      end

      #
      # Does the pathname reference refer to the gloo system object?
      #
      def gloo_sys?
        return false unless @elements&.count&.positive?

        o = @elements.first.downcase
        return true if o == Gloo::Core::GlooSystem.typename
        return true if o == Gloo::Core::GlooSystem.short_typename

        return false
      end

      #
      # Get the string representation of the pathname.
      #
      def to_s
        return @src
      end

      #
      # Set the object pathname to the given value.
      #
      def set_to( value )
        @src = value.nil? ? nil : value.strip
        @elements = @src.nil? ? [] : @src.split( '.' )
      end

      #
      # Convert the raw string to a list of segments.
      #
      def segments
        return @elements
      end

      #
      # Get the name element.
      #
      def name
        return '' unless self.named?

        return @elements.last
      end

      #
      # Does the value include path elements?
      #
      def named?
        return @elements.count.positive?
      end

      #
      # Does the value include a name?
      #
      def includes_path?
        return @elements.count > 1
      end

      # 
      # Does the path start with the context?
      # 
      def includes_context?
        return @src.start_with?( "#{CONTEXT}." )
      end

      # 
      # Expand the context so we have the full path.
      # 
      def expand_context
        # return unless @engine.heap.context
        self.set_to( "#{@engine.heap.context}#{@src[1..-1]}" )
      end

      #
      # Expand any here (^) or context (@) reference into the
      # full path, so the lookup below starts from the heap root.
      #
      def expand_refs
        Here.expand_here( @engine, self ) if Here.includes_here_ref?( @elements )
        expand_context if self.includes_context?
      end

      #
      # Get the parent that contains the object referenced.
      #
      # This is a lookup, not a use of the object: a missing element
      # returns nil without reporting an error. A caller that needs the
      # object reports its own error.
      #
      def get_parent
        o = @engine.heap.root

        if self.includes_path?
          @elements[ 0..-2 ].each do |e|
            o = o.find_child( e )
            return nil if o.nil?
          end
        end

        return o
      end

      #
      # Does the object at the path exist?
      # A question, so a missing object is an answer, not an error.
      #
      def exists?
        return true if self.root?
        return true if self.it?
        return true if self.error?

        expand_refs
        parent = self.get_parent
        return false unless parent

        return parent.contains_child? name
      end

      #
      # Is the reference to a color?
      #
      def named_color?
        return true if NAMED_COLORS.include?( @src.downcase )

        return false
      end

      #
      # Resolve the pathname reference.
      # Find the object referenced or return nil if it is not found.
      # Like get_parent, a missing object is not reported here.
      #
      def resolve
        return @engine.heap.root if self.root?
        return @engine.heap.it if self.it?
        return @engine.heap.error if self.error?
        return Gloo::Core::GlooSystem.new(
          @engine, self ) if self.gloo_sys?

        expand_refs
        parent = self.get_parent
        return nil unless parent

        obj = parent.find_child( self.name )
        return Gloo::Objs::Alias.resolve_alias( @engine, obj, self.src )
      end

    end
  end
end
