# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Get statistics about a development project.
#

module Gloo
  module Objs
    class Stats < GlooLang::Core::Obj

      KEYWORD = 'stats'.freeze
      KEYWORD_SHORT = 'stat'.freeze
      FOLDER = 'folder'.freeze
      TYPES = 'types'.freeze
      SKIP = 'skip'.freeze

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
        o = find_child FOLDER
        return o ? o.value : nil
      end

      #
      # The code file types to count.
      #
      def types_value
        o = find_child TYPES
        return o ? o.value : ''
      end

      #
      # Get the list of files and folders to skip.
      #
      def skip_list
        o = find_child SKIP
        val = o ? o.value : ''
        return val.split ' '
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
        fac.create_file FOLDER, '', self
        fac.create_string TYPES, '', self
        fac.create_can SKIP, self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        all = %w[show_all]
        more = %w[show_busy_folders show_types]
        return super + all + more
      end

      #
      # Show all project stats.
      #
      def msg_show_all
        o = GlooLang::Utils::Stats.new(
          @engine, path_value, types_value, skip_list )
        o.show_all
      end

      #
      # Show file types.
      #
      def msg_show_types
        o = GlooLang::Utils::Stats.new(
          @engine, path_value, types_value, skip_list )
        o.file_types
      end

      #
      # Show busy folders: those with the most files.
      #
      def msg_show_busy_folders
        o = GlooLang::Utils::Stats.new(
          @engine, path_value, types_value, skip_list )
        o.busy_folders
      end

    end
  end
end
