# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2025 Eric Crane.  All rights reserved.
#
# A object to generate an HTML outline.
#

module Gloo
  module Objs
    class Outline < Gloo::Core::Obj

      KEYWORD = 'outline'.freeze
      KEYWORD_SHORT = 'outline'.freeze

      OBJ_SOURCE = 'object_source'.freeze
      DATA = 'data'.freeze
      SEPARATOR = 'separator_char'.freeze
      DEFAULT_SEPARATOR = '/'.freeze
      ENTITY_PATH = 'entity_path'.freeze

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Get the source value of the object.
      # Returns nil if there is none.
      #
      def obj_source
        o = find_child OBJ_SOURCE
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o
      end

      # 
      # Get the separator character.
      #
      def separator_char
        o = find_child SEPARATOR
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o&.value || DEFAULT_SEPARATOR
      end

      #
      # Get the data value of the object.
      # This might be encrypted or decrypted based on 
      # what action was last taken.
      #
      def data
        o = find_child DATA
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o&.value
      end

      #
      # Get the entity path.
      #
      def entity_path
        o = find_child ENTITY_PATH
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o&.value
      end

      #
      # Update the data value of the object.
      #
      def update_data( new_val )
        o = find_child DATA
        return unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return unless o

        o.set_value new_val
      end


      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory
        fac.create_alias OBJ_SOURCE, nil, self
        fac.create_string ENTITY_PATH, nil, self
        fac.create_string SEPARATOR, '/', self
        fac.create_string DATA, nil, self
      end

      
      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[generate]
      end

      #
      # Generate an outline from the source objects.
      #
      def msg_generate
        @root = { name: 'root', id: nil, children: [] }
        
        # Get Topics from the source container
        src = obj_source
        return unless src
        
        # Build the outline structure
        src.children.each do |o|
          id = o.children[0].value
          name = o.children[1].value
          add_topic id, name
        end

        # Generate the HTML from the outline structure
        html = render_outline
  
        # Update the data value
        update_data( html )
      end


      # ---------------------------------------------------------------------
      #    Builder Methods
      # ---------------------------------------------------------------------

      # 
      # Add the item to the topics array, but break 
      # multi-segment topics into component segments.
      # 
      def add_topic id, name
        segments = name.split( separator_char )
        path_segments = segments[0..-2]
        last_segment = segments.last
        parent = @root

        if segments.count > 1
          path_segments.each do |segment|
            parent = find_segment( parent, segment )
          end
        end

        add_item( parent, last_segment, id )
      end

      # 
      # Add the item to the container.
      # Used to create the leaf of the tree.
      # It might be a branch later on.
      # 
      def add_item( in_container, name, id )
        item = { name: name, children: [], id: id }
        in_container[ :children ] << item
      end

      # 
      # Find the segment.
      # If not found, create it.
      # 
      def find_segment( in_container, name )
        in_container[ :children ].each do |item|
          if item[ :name ] == name
            return item
          end
        end

        # Container not found, create it.
        item = { name: name, id: nil, children: [] }
        in_container[ :children ] << item
        return item
      end


      # ---------------------------------------------------------------------
      #    Render Methods
      # ---------------------------------------------------------------------

      # 
      # Render Outline
      # 
      def render_outline
        @html = ""
        @path = entity_path
        render_outline_r( @root[ :children ] )

        return @html
      end

      # 
      # Render the outline recursively.
      # 
      def render_outline_r( in_container )
        @html << "<ul>\n"
        in_container.each do |item|
          if item[ :id ] && @path
            url = "#{@path}#{item[ :id ]}"
            @html << "<li><a href='#{url}'>#{item[ :name ]}</a></li>\n"
          else
            @html << "<li>#{item[ :name ]}</li>\n"
          end
          if item[ :children ] && ( item[ :children ].count > 0 )
            render_outline_r( item[ :children ] )
          end
        end
        @html << "</ul>\n"
      end


      # ---------------------------------------------------------------------
      #    Debugging Methods
      # ---------------------------------------------------------------------

      # 
      # Debugging Tool shows topic hierarchy in console.
      # This is a recursive function.
      # 
      def show_items_r( in_container, indent )
        in_container.each do |item|
          puts "#{' ' * indent}#{item[ :name ]} (#{item[ :id ]})"
          if item[ :children ] && ( item[ :children ].count > 0 )
            show_items_r( item[ :children ], indent + 3 )
          end
        end
      end

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Convert strings with a path to a hierarchical outline.',
          :children => [
            'object_source (alias) — Points to the data source. Should be a container with objects, each of which has a name and optionally an id.',
            'entity_path (string) — The path to the entity, used to generate links to entities that have IDs.',
            "separator_char (string) — Optional. If not specified, the '/' character is used. The character used to separate the path elements.",
            'data (string) — The generated outline: a hierarchical outline of OL and LI elements. For children with IDs, links to entities are included.'
          ],
          :messages => [
            'generate — Generate the outline from the list of strings.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Convert flat elements to hierarchal outline.
            #

            outline [container] :

              on_load [script] :
                tell outline.util to generate
                show outline.util.data

              src_data [container] :
                1 [container] :
                  id [int] : 1
                  name [string] : a/b/c
                2 [container] :
                  id [int] : 2
                  name [string] : a/b/d
                3 [container] :
                  id [int] : 3
                  name [string] : a/b/e
                4 [container] :
                  id [int] : 4
                  name [string] : x
                5 [container] :
                  id [int] : 5
                  name [string] : x/y
                6 [container] :
                  id [int] : 6
                  name [string] : x/y/z
                7 [container] :
                  id [int] : 7
                  name [string] : last

              util [outline] :
                object_source [alias] : outline.src_data
                entity_path [string] : /entity/
                separator_char [string] : /
                data [string] :
          EXAMPLES
        }
      end

    end
  end
end
