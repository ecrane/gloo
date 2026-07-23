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
      # Show the documentation in the terminal.
      def show_in_terminal
        show_name
        show_description
        show_syntax
        show_parameters
        show_children
        show_messages
        show_result
        show_errors
        show_examples
        puts
      end

      private

      #
      # Show the name and shortcut, if there is a name.
      def show_name
        return unless @name

        puts
        puts NAME
        puts @name.white
        puts @shortcut.white if @shortcut
      end

      #
      # Show the description, if there is one.
      def show_description
        return unless @description

        puts
        puts DESCRIPTION
        puts @description.white
      end

      #
      # Show the syntax lines, if there are any.
      def show_syntax
        return unless @syntax

        puts
        puts SYNTAX
        @syntax.each do |line|
          puts TAB + line.white
        end
      end

      #
      # Show the parameter lines, if there are any.
      def show_parameters
        return unless @parameters

        puts
        puts PARAMETERS
        @parameters.each do |line|
          puts TAB + line
        end
      end

      #
      # Show the child lines, if there are any.
      def show_children
        return unless @children

        puts
        puts CHILDREN
        @children.each do |line|
          puts TAB + line
        end
      end

      #
      # Show the message lines, if there are any.
      def show_messages
        return unless @messages

        puts
        puts MESSAGES
        @messages.each do |line|
          puts TAB + line
        end
      end

      #
      # Show the result, if there is one.
      def show_result
        return unless @result

        puts
        puts RESULT
        puts @result
      end

      #
      # Show the error lines, if there are any.
      def show_errors
        return unless @errors

        puts
        puts ERRORS
        @errors.each do |line|
          puts TAB + line
        end
      end

      #
      # Show the example code, if there is any.
      def show_examples
        return unless @examples

        puts
        puts EXAMPLE_CODE
        puts @examples
      end

    end
  end
end
