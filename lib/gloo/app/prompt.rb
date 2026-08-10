# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# CLI input.
#
require 'active_support'
require 'colorize'
require 'colorized_string'
require 'inquirer'
require "reline"

module Gloo
  module App
    class Prompt

      #
      # Set up Prompt.
      #
      # Set up Prompt with the given platform.
      def initialize platform
        @platform = platform
      end

      #
      # Show the prompt and get input.
      # Use the default prompt if none is provided.
      #
      def ask( prompt = nil, default_value = nil )
        prompt ||= default_prompt

        if default_value
          Reline.pre_input_hook = proc { Reline.insert_text( default_value ) }
        end
        response = Reline.readline("#{prompt} ", true)
        Reline.pre_input_hook = nil

        # I don't like this one because it appends a ':' to the prompt.
        # response = Ask.input prompt

        # This was just the brute force way to do it.
        # puts prompt
        # return $stdin.gets.chomp

        return response
      end

      # 
      # Prompt for multiline input.
      # 
      def multiline( prompt )
        puts 'To end input, type a period on a line by itself.'
        text = Reline.readmultiline( "#{prompt} ", true ) do |input|
          input.split.last == '.'
        end
    
        return text.lines[0..-2]
      end

      # 
      # Confirmation prompt.
      # Answer is yes or no.
      # 
      def yes?( prompt )
        value = Ask.confirm "#{prompt} "
        return value
      end

      # 
      # Show a selection list to choose from.
      # 
      def select( prompt, options )
        i = Ask.list prompt, options
        return options[ i ]
      end


      # ---------------------------------------------------------------------
      #    Private Functions
      # ---------------------------------------------------------------------

      private

      #
      # Get the default prompt text.
      #
      def default_prompt
        dt = DateTime.now
        d = dt.strftime( '%Y.%m.%d' )
        t = dt.strftime( '%I:%M:%S' )
        theme = @platform.theme
        return "#{theme.heading( 'gloo' )} #{theme.accent( d )} #{theme.emphasis( t )} >"
      end

    end
  end
end
