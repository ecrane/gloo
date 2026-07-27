# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Documentation data for a primitive: a verb or an object.
#

module Gloo
  module Docs
    class DocData

      NAME = 'NAME & SHORTCUT'.freeze
      DESCRIPTION = 'DESCRIPTION'.freeze
      SYNTAX = 'SYNTAX'.freeze
      PARAMETERS = 'PARAMETERS'.freeze
      CHILDREN = 'CHILDREN'.freeze
      MESSAGES = 'MESSAGES'.freeze
      RESULT = 'RESULT'.freeze
      ERRORS = 'ERRORS'.freeze
      EXAMPLE_CODE = 'EXAMPLE_CODE'.freeze
      NOTES = 'NOTES'.freeze
      TAB = '  '.freeze

      attr_accessor :name, :shortcut, :description, :syntax,
        :parameters, :children, :messages, :result, :errors,
        :examples, :notes

      def initialize( value_hash )
        @name = value_hash[:name]
        @shortcut = value_hash[:shortcut]
        @description = value_hash[:description]
        @syntax = value_hash[:syntax]
        @parameters = value_hash[:parameters]
        @children = value_hash[:children]
        @messages = value_hash[:messages]
        @result = value_hash[:result]
        @errors = value_hash[:errors]
        @examples = value_hash[:examples]
        @notes = value_hash[:notes]
      end

      #
      # Render the documentation as a single string.
      def render
        buf = +''
        add_name buf
        add_description buf
        add_syntax buf
        add_parameters buf
        add_children buf
        add_messages buf
        add_result buf
        add_errors buf
        add_examples buf
        add_notes buf
        buf << "\n"
        return buf
      end

      #
      # Show the documentation in the terminal.
      def show_in_terminal
        puts render
      end

      private

      #
      # Append the name and shortcut, if there is a name.
      def add_name( buf )
        return unless @name

        buf << "\n#{NAME}\n#{@name.white}\n"
        buf << "#{@shortcut.white}\n" if @shortcut
      end

      #
      # Append the description, if there is one.
      def add_description( buf )
        return unless @description

        buf << "\n#{DESCRIPTION}\n#{@description.white}\n"
      end

      #
      # Append the syntax lines, if there are any.
      def add_syntax( buf )
        return unless @syntax

        buf << "\n#{SYNTAX}\n"
        @syntax.each do |line|
          buf << "#{TAB}#{line.white}\n"
        end
      end

      #
      # Append the parameter lines, if there are any.
      def add_parameters( buf )
        return unless @parameters

        buf << "\n#{PARAMETERS}\n"
        @parameters.each do |line|
          buf << "#{TAB}#{line}\n"
        end
      end

      #
      # Append the child lines, if there are any.
      def add_children( buf )
        return unless @children

        buf << "\n#{CHILDREN}\n"
        @children.each do |line|
          buf << "#{TAB}#{line}\n"
        end
      end

      #
      # Append the message lines, if there are any.
      def add_messages( buf )
        return unless @messages

        buf << "\n#{MESSAGES}\n"
        @messages.each do |line|
          buf << "#{TAB}#{line}\n"
        end
      end

      #
      # Append the result, if there is one.
      def add_result( buf )
        return unless @result

        buf << "\n#{RESULT}\n#{@result}\n"
      end

      #
      # Append the error lines, if there are any.
      def add_errors( buf )
        return unless @errors

        buf << "\n#{ERRORS}\n"
        @errors.each do |line|
          buf << "#{TAB}#{line}\n"
        end
      end

      #
      # Append the example code, if there is any.
      def add_examples( buf )
        return unless @examples

        buf << "\n#{EXAMPLE_CODE}\n#{@examples}\n"
      end

      #
      # Append the notes, if there are any.
      def add_notes( buf )
        return unless @notes

        buf << "\n#{NOTES}\n#{@notes}\n"
      end

    end
  end
end
