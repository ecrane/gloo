# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that points to a file in the system.
#

module Gloo
  module Objs
    class FileHandle < Gloo::Core::Obj

      KEYWORD = 'file'.freeze
      KEYWORD_SHORT = 'dir'.freeze

      FILE_NAME_ERR = 'file and path name expected'.freeze
      FILE_MISSING_ERR = 'file not found'.freeze


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
        basic = %w[read write delete get_name get_ext get_parent get_sha256]
        checks = %w[exists? is_file? is_dir? mkdir]
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
        return unless check_file_exists?

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
      # Delete the file.
      #
      def msg_delete
        return unless value
        File.delete( value )
      end

      #
      # Check to see if the file exists.
      #
      def msg_exists?
        result = File.exist? value
        @engine.heap.it.set_to result
      end

      #
      # Check to see if the file is a file.
      #
      def msg_is_file?
        result = File.file? value
        @engine.heap.it.set_to result
      end

      #
      # Check to see if the file is a directory.
      #
      def msg_is_dir?
        result = File.directory? value
        @engine.heap.it.set_to result
      end

      #
      # Create a directory.
      #
      def msg_mkdir
        FileUtils.mkdir_p(value) unless Dir.exist?(value)
        # Dir.mkdir(value) unless Dir.exist?(value)
      end

      #
      # Look for any file matching pattern.
      #
      def msg_find_match
        result = !Dir.glob( value ).empty?
        @engine.heap.it.set_to result
      end

      #
      # Get the name of the file.
      #
      def msg_get_name
        if value.blank?
          @engine.heap.it.set_to ''
        else
          file_name = File.basename( value, File.extname( value ) )
          @engine.heap.it.set_to file_name
        end
      end

      #
      # Get the file's extension.
      #
      def msg_get_ext
        if value.blank?
          @engine.heap.it.set_to ''
        else
          @engine.heap.it.set_to File.extname( value )
        end
      end

      # 
      # Get the parent directory of the file.
      # 
      def msg_get_parent
        if value.blank?
          @engine.heap.it.set_to ''
        else
          @engine.heap.it.set_to File.dirname( value )
        end
      end

      #
      # Get the SHA256 hash of the file contents.
      #
      def msg_get_sha256
        return unless check_file_exists?

        file_hash = FileHandle.hash_for_file( value )
        @engine.heap.it.set_to file_hash
      end

      # 
      # Get the SHA256 hash of the file contents.
      #
      def self.hash_for_file( file_path )
        require 'digest'
        file_data = File.read( file_path )
        file_hash = Digest::SHA256.hexdigest( file_data )
        return file_hash
      end

      #
      # Check to see if the file exists.
      # Show error if not.
      #
      def check_file_exists?
        if value.blank?
          @engine.log.error FILE_NAME_ERR
          return false
        end

        unless File.exist?( value )
          @engine.log.error FILE_MISSING_ERR
          return false
        end

        return true
      end

    end
  end
end
