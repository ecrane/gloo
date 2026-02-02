# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A looping construct...do something for each whatever in something.
# This object has several possible uses:
#   - each child in a container
#   - each word in a string
#   - each line in a string
#   - each file in a directory
#   - each git repo in a directory
#

module Gloo
  module Objs
    class Each < Gloo::Core::Obj

      KEYWORD = 'each'.freeze
      KEYWORD_SHORT = 'each'.freeze
      WORD = 'word'.freeze
      DO = 'do'.freeze
      IN = 'IN'.freeze

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
      # Get the URI from the child object.
      # Returns nil if there is none.
      #
      def in_value
        return find_child_value IN
      end

      #
      # Run the do script once.
      #
      def run_do
        o = find_child DO
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
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
        fac.create_string WORD, '', self
        fac.create_string IN, '', self
        fac.create_script DO, '', self
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'run' ]
      end

      # Run the system command.
      def msg_run
        if EachChild.use_for?( self )
          EachChild.new( @engine, self ).run
        elsif EachWord.use_for?( self )
          EachWord.new( @engine, self ).run
        elsif EachLine.use_for?( self )
          EachLine.new( @engine, self ).run
        elsif EachFile.use_for?( self )
          EachFile.new( @engine, self ).run
        # elsif EachRepo.use_for?( self )
        #   EachRepo.new( @engine, self ).run
        else 
          @engine.err "Not set up to run each for that target."
        end
      end

    end
  end
end
