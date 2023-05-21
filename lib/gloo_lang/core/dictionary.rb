# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A dictionary of Objects and Verbs.
#
require 'singleton'

module GlooLang
  module Core
    class Dictionary

      include Singleton

      attr_reader :verbs, :objs, :keywords

      #
      # Set up the object dictionary.
      #
      def initialize
        @verbs = {}
        @objs = {}
        @verb_references = []
        @obj_references = []
        @keywords = []
      end

      #
      # Get the singleton Dictionary and Initialize
      # if this is the first time.
      #
      def self.get
        o = GlooLang::Core::Dictionary.instance
        o.init if o.verbs.count == 0
        return o
      end

      #
      # Register a verb.
      #
      def register_verb( subclass )
        @verb_references << subclass
      end

      #
      # Register an object type.
      #
      def register_obj( subclass )
        @obj_references << subclass
      end

      #
      # Initialize verbs and objects in the dictionary.
      #
      def init
        # @engine.log.debug 'initializing dictionaries'
        init_verbs
        init_objs
      end

      #
      # Is the given word an object type?
      #
      def obj?( word )
        return false unless word

        return @objs.key?( word.downcase )
      end

      #
      # Find the object type by name.
      #
      def find_obj( word )
        return nil unless word
        return nil unless obj?( word )

        return @objs[ word.downcase ]
      end

      #
      # Is the given word a verb?
      #
      def verb?( word )
        return false unless word

        return @verbs.key?( word.downcase )
      end

      #
      # Find the verb by name.
      #
      def find_verb( verb )
        return nil unless verb
        return nil unless verb?( verb )

        return @verbs[ verb.downcase ]
      end

      #
      # Get the list of verbs, sorted.
      #
      def get_obj_types
        return @obj_references.sort { |a, b| a.typename <=> b.typename }
      end

      #
      # Get the list of verbs, sorted.
      #
      def get_verbs
        return @verb_references.sort { |a, b| a.keyword <=> b.keyword }
      end

      #
      # Lookup the keyword by name or shortcut.
      # Return the keyword (name) or nil if it is not found.
      #
      def lookup_keyword( key )
        v = find_verb key
        return v.keyword if v

        o = find_obj key
        return o.typename if o

        return nil
      end

      #
      # Show a list of all keywords.
      # This includes verbs and objects, names and shortcuts.
      #
      def show_keywords
        str = ''
        @keywords.sort.each_with_index do |k, i|
          str << k.ljust( 20, ' ' )
          if ( ( i + 1 ) % 6 ).zero?
            puts str
            str = ''
          end
        end
      end

      # ---------------------------------------------------------------------
      #    Register after start up
      # ---------------------------------------------------------------------

      #
      # Register a verb after start up.
      #
      def register_verb_post_start( verb_class )
        add_verb verb_class
      end

      #
      # Register an object type after start up.
      #
      def register_obj_post_start( obj_class )
        add_object obj_class
      end

      #
      # Un-Register a verb.
      #
      def unregister_verb( verb_class )
        @verbs.delete( verb_class.keyword )
        @verbs.delete( verb_class.keyword_shortcut )

        @keywords.delete( verb_class.keyword )
        @keywords.delete( verb_class.keyword_shortcut )
      end

      #
      # Un-Register an object.
      #
      def unregister_obj( obj_class )
        @objs.delete( obj_class.typename )
        @objs.delete( obj_class.short_typename )

        @keywords.delete( obj_class.typename )
        @keywords.delete( obj_class.short_typename )
      end

      # ---------------------------------------------------------------------
      #    Private
      # ---------------------------------------------------------------------

      private

      #
      # Add a keyword to the keyword list.
      # Report an error if the keyword is already in the list.
      #
      def add_key( keyword )
        if @keywords.include?( keyword )
          # @engine.log.error "duplicate keyword '#{keyword}'"
          return
        end

        @keywords << keyword
      end

      #
      # Init the list of objects.
      #
      def init_objs
        # @engine.log.debug "initializing #{@obj_references.count} objects"
        @obj_references.each do |o|
          add_object o
        end
      end

      #
      # Init the list of verbs.
      #
      def init_verbs
        # @engine.log.debug "initializing #{@verb_references.count} verbs"
        @verb_references.each do |v|
          add_verb v
        end
      end

      # 
      # Add an object to the dictionary
      # 
      def add_object o
        # @engine.log.debug o
        @objs[ o.typename ] = o
        @objs[ o.short_typename ] = o
        add_key o.typename
        add_key o.short_typename if o.typename != o.short_typename
      end

      # 
      # Add a verb to the dictionary
      # 
      def add_verb v
        # @engine.log.debug v
        @verbs[ v.keyword ] = v
        @verbs[ v.keyword_shortcut ] = v
        # v.send( :new ).run
        add_key v.keyword
        add_key v.keyword_shortcut if v.keyword != v.keyword_shortcut
      end

    end
  end
end
