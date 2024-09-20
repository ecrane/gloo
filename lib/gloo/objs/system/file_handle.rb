# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that points to a file in the system.
#
# require 'tty-pager'

module Gloo
  module Objs
    class FileHandle < Gloo::Core::Obj

      KEYWORD = 'file'.freeze
      KEYWORD_SHORT = 'dir'.freeze

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

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        basic = %w[read write]
        checks = %w[check_exists check_is_file check_is_dir]
        search = %w[find_match]
        show = %w[show page open]
        return super + basic + show + checks + search
      end

      #
      # Open the file in the default application for the file type.
      #
      def msg_open
        return unless value && File.exist?( value )

        cmd = Gloo::Core::GlooSystem.open_for_platform
        cmd_with_param = "#{cmd} \"#{value}\""
        `#{cmd_with_param}`
      end

      #
      # Show the contents of the file, paginated.
      #
      def msg_page
        return unless value && File.file?( value )

        system "less #{value}"
      end

      #
      # Show the contents of the file.
      #
      def msg_show
        return unless value && File.file?( value )

        puts File.read( value )
      end

      #
      # Read the contents of the file into the object.
      #
      def msg_read
        return unless value && File.file?( value )

        data = File.read( value )
        if @params&.token_count&.positive?
          pn = Gloo::Core::Pn.new( @engine, @params.first )
          o = pn.resolve
          o.set_value data
        else
          @engine.heap.it.set_to data
        end
      end

      #
      # Write the given data out to the file.
      #
      def msg_write
        data = ''
        return unless value

        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
        end
        File.write( value, data )
      end

      #
      # Check to see if the file exists.
      #
      def msg_check_exists
        result = File.exist? value
        @engine.heap.it.set_to result
      end

      #
      # Check to see if the file is a file.
      #
      def msg_check_is_file
        result = File.file? value
        @engine.heap.it.set_to result
      end

      #
      # Check to see if the file is a directory.
      #
      def msg_check_is_dir
        result = File.directory? value
        @engine.heap.it.set_to result
      end

      #
      # Look for any file matching pattern.
      #
      def msg_find_match
        result = !Dir.glob( value ).empty?
        @engine.heap.it.set_to result
      end

    end
  end
end
