# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Iterate over each repo in a directory.
# 

module Gloo
  module Objs
    class EachRepo

      FILE = 'file'.freeze
      REPO = 'repo'.freeze

      
      # ---------------------------------------------------------------------
      #    Create Iterator
      # ---------------------------------------------------------------------

      def initialize( engine, iterator_obj )
        @engine = engine
        @iterator_obj = iterator_obj
      end


      # ---------------------------------------------------------------------
      #    Check if this is the right iterator
      # ---------------------------------------------------------------------

      #
      # Use this iterator for each loop?
      #
      def self.use_for?( iterator_obj )
        return true if iterator_obj.find_child REPO

        return false
      end


      # ---------------------------------------------------------------------
      #    Iterate
      # ---------------------------------------------------------------------

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
      # Run for repo.
      #
      def run
        path = @iterator_obj.in_value
        return unless path

        path = Pathname.new( path )
        repos = find_all_git_projects( path )
        repos.each do |o|
          set_repo o
          @iterator_obj.run_do
        end
      end

      #
      # Set the value of the repo.
      # This is a path to the repo.
      #
      def set_repo( path )
        o = @iterator_obj.find_child REPO
        return unless o

        o.set_value path
      end
      
    end
  end
end
