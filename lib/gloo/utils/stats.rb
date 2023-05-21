# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Utilities related to words (strings).
#

module Gloo
  module Utils
    class Stats

      DIR_NOT_FOUND_ERR = 'The folder was not found!'.freeze

      # ---------------------------------------------------------------------
      #    Setup
      # ---------------------------------------------------------------------

      #
      # Create a stats utility class for the given directory.
      #
      def initialize( engine, dir, types, skip = [] )
        @engine = engine
        @dir = dir
        setup_loc types
        @skip = skip
      end

      # ---------------------------------------------------------------------
      #    Public Functions
      # ---------------------------------------------------------------------

      #
      # Is the stats utility valid?
      # Does it have a valid root directory.
      #
      def valid?
        return true if @dir && File.directory?( @dir )

        @engine.err DIR_NOT_FOUND_ERR
        @engine.heap.it.set_to false

        return false
      end

      #
      # Show all stat data for the project.
      #
      def show_all
        return unless valid?

        generate
        puts "Showing All stats for #{@dir}".white
        puts "\n ** #{@dir_cnt} Total Folders ** "
        puts " ** #{@file_cnt} Total Files ** "

        busy_folders( 7 )
        file_types
        loc
      end

      #
      # Get a list of the busiest folders.
      # Count is how many results we want.
      #
      def busy_folders( count = 17 )
        return unless valid?

        generate
        puts "\nBusy Folders:".yellow

        @folders.sort! { |a, b| a[ :cnt ] <=> b[ :cnt ] }
        @folders.reverse!
        @folders[ 0..count ].each do |f|
          puts "  #{f[ :cnt ]} - #{f[ :name ]}"
        end
      end

      #
      # Show file types and how many of each there are.
      #
      def file_types
        return unless valid?

        generate
        puts "\nFiles by Type:".yellow

        @types = @types.sort_by( &:last )
        @types.reverse!
        @types.each do |o|
          puts "  #{o[ 1 ]} - #{o[ 0 ]}" unless o[ 0 ].empty?
        end
      end

      #
      # Show Lines of Code
      #
      def loc
        return unless valid?

        generate
        total = 0

        @loc.each do |k, v|
          puts "\n #{k} Lines of Code".yellow
          total += v[ :lines ]
          formatted = Gloo::Utils::Format.number( v[ :lines ] )
          puts " ** #{formatted} in #{v[ :files ].count} #{k} files ** "

          puts "\n Busy #{k} files:".yellow
          files = v[ :files ].sort! { |a, b| a[ :lines ] <=> b[ :lines ] }
          files.reverse!
          files[ 0..12 ].each do |f|
            puts "  #{f[ :lines ]} - #{f[ :file ]}"
          end
        end

        formatted = Gloo::Utils::Format.number( total )
        puts "\n #{formatted} Total Lines of Code".white
      end

      # ---------------------------------------------------------------------
      #    Private Functions
      # ---------------------------------------------------------------------

      #
      # Setup counters for lines of code by file type.
      def setup_loc( types )
        @loc = {}

        types.split( ' ' ).each do |t|
          @loc[ t ] = { lines: 0, files: [] }
        end
      end

      #
      # Generate stat data unless we've already done so.
      #
      def generate
        return if @folders

        @engine.log.debug 'Generating...'
        @folders = []
        @types = {}
        @file_cnt = 0
        @dir_cnt = 0

        generate_for Pathname.new( @dir )
      end

      #
      # Generate data for the given path.
      # NOTE: this is a recursive function.
      # It traverses all sub-direcctories.
      #
      def generate_for( path )
        return if @skip.include?( File.basename( path ) )

        cnt = 0
        path.children.each do |f|
          if f.directory?
            @dir_cnt += 1
            generate_for( f )
          else
            @file_cnt += 1
            cnt += 1
            handle_file( f )
            inc_type( File.extname( f ) )
          end
        end
        @folders << { name: path, cnt: cnt }
      end

      #
      # Increment the file count.
      #
      def inc_type( type )
        if @types[ type ]
          @types[ type ] += 1
        else
          @types[ type ] = 1
        end
      end

      #
      # Consider code file types.
      #
      def handle_file( file )
        ext = File.extname( file )
        return unless ext

        ext = ext[ 1..-1 ]
        return unless @loc.key?( ext )

        lines = count_lines( file )
        @loc[ ext ][ :lines ] += lines
        @loc[ ext ][ :files ] << { lines: lines, file: file }
      end

      #
      # Count lines of code in file.
      def count_lines( file )
        return `wc -l #{file}`.split.first.to_i
      end

    end
  end
end
