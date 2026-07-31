# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Documentation data for a primitive: a verb or an object.
#
# Renders as plain markdown - no color/ANSI here. Color is applied
# separately, at display time, by Gloo::Docs::MarkdownRenderer, so
# this stays reusable wherever the raw markdown is useful (paging,
# export, tests).
#

module Gloo
  module Docs
    class DocData

      DESCRIPTION = '## Description'.freeze
      SYNTAX = '## Syntax'.freeze
      PARAMETERS = '## Parameters'.freeze
      CHILDREN = '## Children'.freeze
      MESSAGES = '## Messages'.freeze
      RESULT = '## Result'.freeze
      ERRORS = '## Errors'.freeze
      EXAMPLES = '## Examples'.freeze
      NOTES = '## Notes'.freeze
      FENCE = '```gloo'.freeze

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
      # Render the documentation as a markdown string.
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

        buf << "\n# #{@name}\n"
        buf << "#{@shortcut}\n" if @shortcut
      end

      #
      # Append the description, if there is one.
      def add_description( buf )
        return unless @description

        buf << "\n#{DESCRIPTION}\n#{@description}\n"
      end

      #
      # Append the syntax lines, if there are any.
      def add_syntax( buf )
        return unless @syntax

        buf << "\n#{SYNTAX}\n#{FENCE}\n"
        @syntax.each { |line| buf << "#{line}\n" }
        buf << "```\n"
      end

      #
      # Append the parameter lines, if there are any.
      def add_parameters( buf )
        return unless @parameters

        buf << "\n#{PARAMETERS}\n"
        @parameters.each { |line| buf << "- #{line}\n" }
      end

      #
      # Append the child lines, if there are any.
      def add_children( buf )
        return unless @children

        buf << "\n#{CHILDREN}\n"
        @children.each { |line| buf << "- #{line}\n" }
      end

      #
      # Append the message lines, if there are any.
      def add_messages( buf )
        return unless @messages

        buf << "\n#{MESSAGES}\n"
        @messages.each { |line| buf << "- #{line}\n" }
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
        @errors.each { |line| buf << "- #{line}\n" }
      end

      #
      # Append the example code, if there is any.
      def add_examples( buf )
        return unless @examples

        buf << "\n#{EXAMPLES}\n#{FENCE}\n#{@examples}\n```\n"
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
