# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# The one wording for "not found" errors, so every command reports
# a missing object, file, folder or verb the same way.
#

module Gloo
  module Core
    module NotFound

      #
      # An object path that doesn't resolve, shown as written.
      #
      def self.object( path )
        return "Object '#{path}' was not found."
      end

      #
      # A file that doesn't exist.
      #
      def self.file( name )
        return "File '#{name}' was not found."
      end

      #
      # A folder that doesn't exist.
      #
      def self.folder( name )
        return "Folder '#{name}' was not found."
      end

      #
      # A verb that isn't in the dictionary.
      #
      def self.verb( name )
        return "Verb '#{name}' was not found."
      end

    end
  end
end
