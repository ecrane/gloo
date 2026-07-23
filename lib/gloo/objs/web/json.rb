# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# JSON data.
#
require 'json'

module Gloo
  module Objs
    class Json < Gloo::Core::Obj

      KEYWORD = 'json'.freeze
      KEYWORD_SHORT = 'json'.freeze

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
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value.to_s
      end

      #
      # Does this object support multi-line values?
      # Initially only true for scripts.
      #
      def multiline_value?
        return false
      end

      #
      # Get the number of lines of text.
      #
      def line_count
        return value.split( "\n" ).count
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[get set parse pretty]
      end

      #
      # Make the JSON pretty.
      #
      def msg_pretty
        return unless self.value

        json = JSON.parse( self.value )
        if self.value.start_with?( '"{' )
          json = JSON.parse( json )
        end
        pretty = JSON.pretty_generate( json )
        set_value pretty
      end

      #
      # Get a value from the JSON data.
      # The additional parameter is the path to the value.
      #
      def msg_get
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
        end
        return unless data

        field = Gloo::Objs::Json.get_value_in_json self.value, data
        @engine.heap.it.set_to field
        return field
      end

      #
      # Convert the target object to JSON and set the value of
      # this JSON to that value.
      #
      def msg_set
        if @params&.token_count&.positive?
          pn = Gloo::Core::Pn.new( @engine, @params.tokens.first )
          unless pn&.exists?
            @engine.err 'Source path for objects does not exist'
            return
          end
        else
          @engine.err 'Source path for objects is required'
          return
        end
        parent = pn.resolve

        h = Json.convert_obj_to_hash( parent )
        json = JSON.parse( h.to_json )
        json = JSON.pretty_generate( json )

        set_value json
        @engine.heap.it.set_to json
        return json
      end

      #
      # Parse the JSON data and put it in objects.
      # The additional parameter is the path to the destination
      # for the parsed objects.
      #
      def msg_parse
        if @params&.token_count&.positive?
          pn = Gloo::Core::Pn.new( @engine, @params.tokens.first )
          unless pn&.exists?
            @engine.err 'Destination path for parsed objects does not exist'
            return
          end
        else
          @engine.err 'Destination path for parsed objects is required'
          return
        end
        parent = pn.resolve

        json = JSON.parse( self.value )
        self.handle_json_to_obj( json, parent )
      end

      # ---------------------------------------------------------------------
      #    JSON Helper functions
      # ---------------------------------------------------------------------

      # 
      # Convert the object to JSON.
      # 
      def self.convert_obj_to_json( obj )
        h = obj ? convert_obj_to_hash( obj ) : {}
        json = JSON.parse( h.to_json )
        json = JSON.pretty_generate( json )
        return json
      end

      # 
      # Convert the object to a hash of name and values.
      # 
      def self.convert_obj_to_hash( obj )
        h = {}

        if obj.child_count > 0
          obj.children.each do |child|
            h[ child.name ] = convert_obj_to_hash( child )
          end
        else
          return obj.value
        end

        return h
      end

      #
      # Handle JSON, creating objects and setting values.
      # Note that this is a recursive function.
      #
      def handle_json_to_obj( json, parent )
        if json.class == Hash
          json.each do |k, v|
            if ( v.class == Array ) || ( v.class == Hash )
              o = parent.find_add_child( k, 'can' )
              handle_json_to_obj( v, o )
            else
              o = parent.find_add_child( k, 'untyped' )
              o.set_value v
            end
          end
        elsif json.class == Array
          json.each_with_index do |o, index|
            child = parent.find_add_child( index.to_s, 'can' )
            handle_json_to_obj( o, child )
          end
        end
      end

      # 
      # Parse the JSON data and look for the value within it.
      # 
      def self.get_value_in_json( json, path_to_value )
        data = JSON.parse( json )
        path_to_value.split( '.' ).each do |segment|
          data = data[ segment ]
        end
        return data
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
          :description => 'JSON data in a text string.',
          :messages => [
            'get ({path}) — Get a value from the JSON data. Example: tell myjson to get (\'title\'). The parameter is the path in JSON to the value we want. The value is put into it.',
            'set ({obj.path}) — Convert an object to an approximate JSON value. Example: tell myjson to set (my.object). The parameter is the path to the object used as the source. Note this is an approximate conversion — a gloo object can have both a simple value and be a container for child objects, which JSON can\'t represent the same way.',
            'parse ({dst.path}) — Parse the JSON data and put values in the object specified by the parameter. Example: tell myjson to parse (path.to.dst).',
            'pretty — Make the JSON format pretty.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Get values from within a JSON object.
            #

            json_get [can] :
              on_load [script] :
                tell json_get.payload to get ('msg')
                show it
                tell json_get.payload to get ('sub.data')
                show it
                tell json_get.payload to get ('sub.child.msg')
                show it
              payload [json] : BEGIN
                { "msg":"The message from inside a JSON block",
                  "sub":{"data":"in sub-object",
                    "child":{"msg":"third level"}} }
                END
          EXAMPLES
        }
      end

    end
  end
end
