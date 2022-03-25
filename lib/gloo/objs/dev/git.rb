# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that interacts with a git repository
#

module Gloo
  module Objs
    class Git < GlooLang::Core::Obj

      KEYWORD = 'git_repo'.freeze
      KEYWORD_SHORT = 'git'.freeze

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
      # Get the path to the git repo (locally).
      #
      def path_value
        return value
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        actions = %w[validate commit get_branch review]
        changes = %w[check_changes get_changes]
        return super + changes + actions
      end

      #
      # Get the current working branch.
      #
      def msg_get_branch
        branch = ''
        path = path_value
        if path_is_dir?( path )
          branch = `cd #{path}; git rev-parse --abbrev-ref HEAD`
          branch = branch.strip
        end

        @engine.heap.it.set_to branch
      end

      #
      # Review pending changes.
      #
      def msg_review
        $log.debug 'Reviewing pending changes'
        cmd = "cd #{path_value}; git diff"
        $log.debug cmd
        system cmd
      end

      #
      # Commit pending changes.
      #
      def msg_commit
        msg = 'Commit'
        path = path_value
        if path_is_dir?( path )
          if @params&.token_count&.positive?
            expr = GlooLang::Expr::Expression.new( @engine, @params.tokens )
            msg = expr.evaluate
          end
          branch = `cd #{path}; git rev-parse --abbrev-ref HEAD`
          branch = branch.strip
          add = 'git add .'
          cmt = 'git commit -m '
          psh = 'git push origin '
          `cd #{path};#{add};#{cmt}"#{msg}";#{psh}#{branch}`
        end
        @engine.heap.it.set_to msg
      end

      #
      # Get the pending changes.
      #
      def msg_get_changes
        path = path_value
        result = `cd #{path}; git status -s` if path_is_dir?( path )
        result ||= ''
        @engine.heap.it.set_to result
      end

      #
      # Is the given path non nil and is it a directory?
      #
      def path_is_dir?( path )
        return path && File.directory?( path )
      end

      #
      # Check to see if the repo has changes.
      #
      def msg_check_changes
        result = false
        path = path_value
        if path_is_dir?( path )
          data = `cd #{path}; git status -s`
          result = true unless data.strip.empty?
        end

        @engine.heap.it.set_to result
      end

      #
      # Check to make sure this is a valide git repo.
      #
      def msg_validate
        result = false
        path = path_value
        if path_is_dir?( path )
          pn = File.join( path, '.git' )
          result = File.exist? pn
        end

        @engine.heap.it.set_to result
      end

    end
  end
end
