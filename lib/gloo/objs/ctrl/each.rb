# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A looping construct...do something for each whatever in something.
# This object has several possible uses:
#   - each word in a string
#   - each line in a string
#   - each file in a directory
#   - each git repo in a directory
#

module Gloo
  module Objs
    class Each < GlooLang::Core::Obj

      KEYWORD = 'each'.freeze
      KEYWORD_SHORT = 'each'.freeze
      CHILD = 'child'.freeze
      WORD = 'word'.freeze
      LINE = 'line'.freeze
      FILE = 'file'.freeze
      REPO = 'repo'.freeze
      IN = 'IN'.freeze
      DO = 'do'.freeze

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
        o = find_child IN
        return o ? o.value : nil
      end

      #
      # Run the do script once.
      #
      def run_do
        o = find_child DO
        return unless o

        GlooLang::Exec::Dispatch.message( @engine, 'run', o )
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
        if each_child?
          run_each_child
        elsif each_word?
          run_each_word
        elsif each_line?
          run_each_line
        elsif each_repo?
          run_each_repo
        end
      end

      # ---------------------------------------------------------------------
      #    Child Object
      # ---------------------------------------------------------------------

      #
      # Is it set up to run for each word?
      # If there is a child object by the name "word"
      # then we will loop for each word in the string.
      #
      def each_child?
        return true if contains_child? CHILD

        return false
      end

      #
      # Run for each word.
      #
      def run_each_child
        o = find_child IN
        return unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        o.children.each do |child|
          set_child child
          run_do
        end
      end

      #
      # Set the child alias.
      #
      def set_child( obj )
        o = find_child CHILD
        return unless o

        o.set_value obj.pn
      end

      # ---------------------------------------------------------------------
      #    Word
      # ---------------------------------------------------------------------

      #
      # Is it set up to run for each word?
      # If there is a child object by the name "word"
      # then we will loop for each word in the string.
      #
      def each_word?
        return true if find_child WORD

        return false
      end

      #
      # Run for each word.
      #
      def run_each_word
        str = in_value
        return unless str

        str.split( ' ' ).each do |word|
          set_word word
          run_do
        end
      end

      #
      # Set the value of the word.
      #
      def set_word( word )
        o = find_child WORD
        return unless o

        o.set_value word
      end

      # ---------------------------------------------------------------------
      #    Line
      # ---------------------------------------------------------------------

      #
      # Is it set up to run for each line?
      # If there is a child object by the name "line"
      # then we will loop for each line in the string.
      #
      def each_line?
        return true if find_child LINE

        return false
      end

      #
      # Run for each line.
      #
      def run_each_line
        str = in_value
        return unless str

        str.each_line do |line|
          set_line line
          run_do
        end
      end

      #
      # Set the value of the word.
      #
      def set_line( line )
        o = find_child LINE
        return unless o

        o.set_value line
      end

      # ---------------------------------------------------------------------
      #    Git Repo
      # ---------------------------------------------------------------------

      #
      # Is it set up to run for each git repo?
      # If there is a child object by the name "repo"
      # then we will loop for each repo in the directory.
      #
      def each_repo?
        return true if find_child REPO

        return false
      end

      #
      # Find all git projects in a path.
      #
      def find_all_git_projects( path )
        path.children.collect do |f|
          if f.directory? && ( File.basename( f ) == '.git' )
            File.dirname( f )
          elsif f.directory?
            find_all_git_projects( f )
          end
        end.flatten.compact
      end

      #
      # Run for each line.
      #
      def run_each_repo
        path = in_value
        return unless path

        path = Pathname.new( path )
        repos = find_all_git_projects( path )
        repos.each do |o|
          set_repo o
          run_do
        end
      end

      #
      # Set the value of the repo.
      # This is a path to the repo.
      #
      def set_repo( path )
        o = find_child REPO
        return unless o

        o.set_value path
      end

    end
  end
end
