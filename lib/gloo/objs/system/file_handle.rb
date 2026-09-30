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
        basic = %w[read write append delete get_name get_ext get_parent get_sha256]
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
        return unless check_is_file?

        system "less #{value}"
      end

      #
      # Show the contents of the file.
      #
      def msg_show
        return unless check_is_file?

        data = file_op( 'read' ) { File.read( value ) }
        puts data if data
      end

      #
      # Read the contents of the file into the object.
      #
      def msg_read
        return @engine.heap.it.set_to( false ) unless check_file_exists?

        data = file_op( 'read' ) { File.read( value ) }
        return @engine.heap.it.set_to( false ) unless data

        if @params&.token_count&.positive?
          pn = Gloo::Core::Pn.new( @engine, @params.first )
          o = pn.resolve
          unless o
            @engine.err Gloo::Core::NotFound.object( @params.first )
            return @engine.heap.it.set_to( false )
          end

          o.set_value data
        end
        @engine.heap.it.set_to data
      end

      #
      # Append the given data to the file as a new line.
      # Adds a leading newline if the file does not already end with one.
      #
      def msg_append
        data = ''
        return unless value

        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
        end
        file_op( 'append to' ) do
          existing = File.exist?( value ) ? File.read( value ) : ''
          prefix = existing.empty? || existing.end_with?( "\n" ) ? '' : "\n"
          File.open( value, 'a' ) { |f| f.puts "#{prefix}#{data}" }
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
        file_op( 'write' ) { File.write( value, data ) }
      end

      #
      # Delete the file.
      #
      def msg_delete
        return unless value

        file_op( 'delete' ) { File.delete( value ) }
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
        file_op( 'make folder' ) { FileUtils.mkdir_p( value ) } unless Dir.exist?( value )
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
        return @engine.heap.it.set_to( false ) unless check_file_exists?

        file_hash = file_op( 'read' ) { FileHandle.hash_for_file( value ) }
        @engine.heap.it.set_to( file_hash || false )
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
      # Run a file system operation. A failure the file system reports
      # (no such file, a folder where a file was expected, no permission,
      # ...) is a runtime error, and the result is nil.
      #
      def file_op( action )
        return yield
      rescue Errno::ENOENT
        @engine.err Gloo::Core::NotFound.file( value )
        return nil
      rescue SystemCallError => e
        @engine.err "Could not #{action} '#{value}': #{e.message}"
        return nil
      end

      #
      # Check that the file exists and is a file, not a folder.
      # Report an error if not.
      #
      def check_is_file?
        return false unless check_file_exists?
        return true if File.file?( value )

        @engine.err "'#{value}' is a folder, not a file."
        return false
      end

      #
      # Check to see if the file exists.
      # Report an error if not.
      #
      def check_file_exists?
        if value.blank?
          @engine.err FILE_NAME_ERR
          return false
        end

        unless File.exist?( value )
          @engine.err Gloo::Core::NotFound.file( value )
          return false
        end

        return true
      end

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Reference to a file or folder (directory) ' \
            'on disk. The string value of the file object is the path ' \
            'and name of the file.',
          :messages => [
            'read ({into.obj}) — Read the file and put the data in the specified object. If {into.obj} is not specified, the data will be in it. If {into.obj} does not exist, that is an error.',
            'write ({from.obj}) — Write the data in {from.obj} into the file.',
            'append ({data}) — Append the given data to the file as a new line. Adds a leading newline first if the file doesn\'t already end with one.',
            'delete — Delete the file.',
            'get_name — Get the name of the file without path or extension. Put the name into it.',
            'get_ext — Get the file extension. Put the extension into it.',
            'get_parent — Get the file or folder path parent. Put the parent into it.',
            'get_sha256 — Get the SHA256 hash of the contents of the file. Put the hash value into it.',
            'show — Show the contents of the file.',
            'page — Show the contents of the file, paginated.',
            'open — Open the file with the default application for the type.',
            'exists? — Check to see if the file exists. It will be true or false.',
            'is_file? — Check to see if the file specified is a regular file. It will be true or false.',
            'is_dir? — Check to see if the file specified is a directory. It will be true or false.',
            'find_match — Look for the existence of a file matching the file\'s pattern. It will be true or false.',
            'mkdir — Create the file\'s path as a directory, if it doesn\'t already exist.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Get elements of a file name.
            #
            file_name [can] :

              # The full file path, name and extension.
              f [file] : /Users/me/dev/gloo/gloo.gemspec

              on_load [script] :
                show "Full file name:  " + ^.f

                check ^.f for get_name
                show "The file name alone: " and it

                check ^.f for get_ext
                show "The file extension: " and it

                check ^.f for get_parent
                show "The file path: " and it
          EXAMPLES
        }
      end

    end
  end
end
